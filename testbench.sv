
interface class ifc;
  pure virtual function void test();
endclass : ifc

class typeA implements ifc;
  bit    A;
  string s = "typeA";
  function new();
    A = 1'b1;
  endfunction : new
  virtual function void test();
    $display("%t: %s", $time, s);
  endfunction : test
  static function void null_test(string s);
    $display("%t: %s - $cast succeeded", $time, s);
  endfunction : null_test
endclass: typeA

class typeA_ext extends typeA;
  function new();
    super.new();
    A = 1'b0;
    s = "typeA_ext";
  endfunction : new
endclass: typeA_ext


class typeB;
  int    B;
  function new();
    B = 69;
  endfunction : new
endclass: typeB


module test_case;
  ifc        i, i_null;
  typeA      A0, A1, A_null;
  typeA_ext  A0_ext, A1_ext;
  typeB      B, B_null;
  
  // Case 1
  initial begin
    #1;
    $display("Case 1");
    A1     = new();
    A1_ext = new();
    
    $cast(A0, A1);              // It succeeds according to case 1
                                // (same as A0 = A1 - the destination is same type as the source expression)
    A0.test();
    $cast(A0, A1_ext);          // It succeeds according to case 1
                                // (same as A0 = A1_ext - the destination is a superclass of the source expression)
    A0.test();
  end
    
  // Case 2
  initial begin
    #2;
    $display("Case 2");
    A1     = new();
    A1_ext = new();
    
    A0     = A1_ext;
    i      = A1;
    
    $cast(A0_ext, A0);          // It succeeds according to case 2a
                                // in fact, A0 (typeA) is holding an object (A1_ext) of type typeA_ext
    A0.test();
    $cast(A0, i);               // It succeeds according to case 2b
                                // in fact, i (interface class) is holding A1 (typeA)
    A0.test();
  end
    
  // Case 3
  initial begin
    #3;
    $display("Case 3");
    $cast(A0, null);            // It succeeds according to case 3
    A0.null_test("$cast(A0, null)");
  end
    
  // In all other cases $cast shall fail - Let's use $cast as a function to catch the run-time error
  initial begin
    #4;
    $display("All other cases");
    B      = new();
    B_null = null;
    
    if ($cast(A0, B))           // source and destination types are not cast compatible
      $display("%t: $cast(A0, B) - Not expected to succeed", $time);
    else if ($cast(A0, B_null)) // even if the source expression evaluates to null
      $display("%t: $cast(A0, B_null) - Not expected to succeed", $time);
    else
      $display("%t: $cast fails as expected", $time);
  end
    
  // Debatable? Do they fall in "all other cases"? Shall $cast fail?
  initial begin
    #5;
    $display("Debatable?");
    A_null = null;
    i_null = A_null;
    
    $cast(A0, A_null);          // Shouldn't it match case 1  and/or 3?
    A0.null_test("$cast(A0, A_null)");
    $cast(A0, i_null);          // Shouldn't it match case 2b and/or 3?
    A0.null_test("$cast(A0, i_null)");
  end
endmodule
