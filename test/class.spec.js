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

			var parsed = parser.parse('enum bar;');

			expect(parsed).that.is.an('array');
			expect(parsed[0]).that.is.an('object');

			expect(parsed[0]).to.have.all.keys('type','id','body');

			expect(parsed[0]).to.have.property('type','enum');
			expect(parsed[0]).to.have.property('id','bar');
			expect(parsed[0]).to.have.property('body').that.is.undefined;
		  });
		  
		it('Should parse enum with members', function(){

			var parsed = parser.parse('enum bar { RED; BLUE; GREEN; };');

			expect(parsed[0]).to.have.all.keys('type','id','body');

			expect(parsed[0]).to.have.property('type','enum');
			expect(parsed[0]).to.have.property('id','bar');
			expect(parsed[0]).to.have.property('body').that.is.an('array');
			
			expect(parsed[0]).with.deep.property('body[2]').to.be.an('object');
			expect(parsed[0]).with.deep.property('body[2].type','enum member');
			expect(parsed[0]).with.deep.property('body[2].name','GREEN');
		});
		
	}); // end enum tests
	
	describe('Class parse', function(){
		it('Should parse class name w/o body', function(){

			var parsed = parser.parse('class foo');
			
			expect(parsed).that.is.an('array');
			expect(parsed[0]).that.is.an('object');

			expect(parsed[0]).to.have.all.keys('type','id','body','stereotype');

			expect(parsed[0]).to.have.property('id','foo');
			expect(parsed[0]).to.have.property('type','class');
			expect(parsed[0]).to.have.property('stereotype').that.is.undefined;
			expect(parsed[0]) .to.have.property('body').that.is.undefined;
		});
		
		it('Should parse class name w/ namespace', function(){

			var parsed = parser.parse('class baz.foo');
			
			expect(parsed[0]).to.have.all.keys('type','id','body','stereotype');

			expect(parsed[0]).to.have.property('id','baz.foo');
			expect(parsed[0]).to.have.property('type','class');
			expect(parsed[0]).to.have.property('stereotype').that.is.undefined;
			expect(parsed[0]) .to.have.property('body').that.is.undefined;

				
		});
		
		it('Should parse class with single attribute body', function(){
			
			var parsed = parser.parse('class baz.foo { id: int}');

			expect(parsed[0]).to.have.all.keys('type','id','body','stereotype');

			expect(parsed[0]).to.have.property('id','baz.foo');
			expect(parsed[0]).to.have.property('type','class');
			expect(parsed[0]).to.have.property('stereotype').that.is.undefined;
			expect(parsed[0]).to.have.property('body').that.is.an('array');
			
			// console.log(require('util').inspect(foo[0], {colors: true}));
			
			expect(parsed[0].body[0]).to.have.all.keys('attributes','data_type','name','scope','stereotype','type');
			
			expect(parsed[0].body[0]).to.have.property('type','property');
			expect(parsed[0].body[0]).to.have.property('name','id');
			expect(parsed[0].body[0]).to.have.property('data_type','int');
			/*
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
			*/

		});
		
		it.skip('Should parse class with single method body', function(){

			var parsed = parser.parse('class foo { void someMethod() }'); 
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
