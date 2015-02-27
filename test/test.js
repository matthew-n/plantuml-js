var expect =  require('chai').expect;
var fs = require('fs');
var PEG = require('pegjs');

describe ('PlantUML Class Diagram', function() {
	var	parser;
	before(function(){
		var grammar;
		grammar = fs.readFileSync('./PlantUML.pegjs', 'utf8');
		parser = PEG.buildParser(grammar);
	});
	
	describe('Enum parse', function() {
		it('Should parse enum w/o members ', function(){		
			var foo = parser.parse('enum bar;');			
			expect(foo[0])
				.that.is.an('object')
				.that.deep.equals({
						type: "enum",
						id: "bar", 
						body: undefined 
				});
		  });
		  
		it('Should parse enum with members', function(){		
			var foo = parser.parse('enum bar { RED; BLUE; GREEN; };');
			expect(foo[0])
				.to.have.property('body')
				.that.is.an('array')
				.that.deep.equals([
						{
							"type": "enum member",
							"name": "RED"
						},
						{
							"type": "enum member",
							"name": "BLUE"
						},
						{
							"type": "enum member",
							"name": "GREEN"
						}
				]);
		});
		
	}); // end enum tests
	
	describe('Class parse', function(){
		it('Should parse class name w/o body', function(){
			var parsed = parser.parse('class foo');
			expect(parsed[0])
				.to.have.all.keys('type','id','body','stereotype');
			expect(parsed[0]).to.have.property('id','foo');
			expect(parsed[0]) .to.have.property('body',undefined);
		});
		
		it('Should parse class name w/ namespace', function(){
			var parsed = parser.parse('class baz.foo');
			expect(parsed[0])
				.to.have.all.keys('type','id','body','stereotype');
			expect(parsed[0]).to.have.property('id','baz.foo');
			expect(parsed[0]).to.have.property('body',undefined);
				
		});
		
		it('Should parse class name with body', function(){
			var parsed = parser.parse('class foo { id: int}');
			expect(parsed[0])
				.to.have.all.keys('type','id','body','stereotype');
			expect(parsed[0]).to.have.property('id','foo');
			expect(parsed[0]).to.have.property('body',undefined);
			
			// console.log(require('util').inspect(foo[0], {colors: true}));
			
			expect(parsed[0])
					.with.deep.property('body[0]')
						.that.is.an('object');
			expect(parsed[0])
				.to.have.property('body')
					.that.is.an('array');
					//.with.deep.property('[0]')
					//	.that.is.an('object');
				//.with.deep.property('[0]')
				//.to.have.all.keys('attributes','data_type','name','scope','stereotype','type');
			// expect(parser.parse('class foo { id: int}')).to
				// .deep.equal([
					  // {
						// "type": "class",
						// "id": "foo",
						// "body": [
						  // {
							// "type": "property",
							// "name": "id",
							// "data_type": "int"
						  // }
						// ]
					  // }
				// ]);
		});
		
		it.skip('Should parse clase name with method', function(){
		});
		
	});// end class tests
	
});// end class diagram tests

/*
describe ('Activity', function() {
	describe.skip('Stub', function() {
	});
});

describe ('Use Case', function() {
	describe.skip('Stub', function() {
	});
});

describe ('Component', function() {
	describe.skip('Stub', function() {
	});
});

describe ('Annotation', function() {
	describe.skip('Stub', function() {
	});
});

*/