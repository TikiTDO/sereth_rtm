describe "test", () ->
  beforeEach () =>
    #@test = new sereth.context

  it "should return 5", () =>
    expect(2).toEqual(2)