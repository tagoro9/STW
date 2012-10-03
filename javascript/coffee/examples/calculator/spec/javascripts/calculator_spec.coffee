describe "Calculator", ->

	beforeEach ->
		@calculator = new Calculator()

	it "is not in scientific mode by default", ->
		expect(@calculator).not.toBeScientific()

	describe "scientific mode", ->

		beforeEach ->
			@calculator = new Calculator(true)

		it "is in scientific mode when set", ->
			expect(@calculator).toBeScientific()

	describe "#add", ->
		it "adds two numbers", ->
			expect(@calculator.add(1,1)).toEqual 2

	describe "#substract", ->
		it "substracts two numbers", ->
			expect(@calculator.substract(10,1)).toEqual 9

	describe "#multiply", ->
		it "multiplies two numbers", ->
			expect(@calculator.multiply(5,4)).toEqual 20

	describe "#divide", ->
		it "divides two numbers", ->
			expect(@calculator.divide(20,5)).toEqual 4