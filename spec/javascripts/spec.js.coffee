describe "test", () ->
  beforeEach () =>
    @test = new AA();

  it "should return 5", () =>
    expect(@test.foo()).toEqual(5)