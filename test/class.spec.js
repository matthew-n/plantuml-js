var expect =  require('chai').expect;
var fs = require('fs');
var PEG = require('pegjs');

describe ('PlantUML Class Diagram', function() {
	var	parser;
	
	function testIsSingleStatment(parsed){
		expect(parsed).to.be.an('array').length(1);
		expect(parsed[0]).to.be.an('object');
	}
	
	before(function(){
		var grammar;
		grammar = fs.readFileSync('./PlantUML.pegjs', 'utf8');
		parser = PEG.buildParser(grammar);
	});
	
	describe('enum definition', function() {
		it('empty defintion', function (){
			var parsed = parser.parse('enum bar;');
			
			testIsSingleStatment(parsed);

			expect(parsed[0]).to.have.all.keys('type','id','body');

			expect(parsed[0]).to.have.property('type','enum');
			expect(parsed[0]).to.have.property('id','bar');
			expect(parsed[0]).to.have.property('body').that.is.null;
		});
		
		it('with members', function(){
			var parsed = parser.parse('enum bar { RED; BLUE; GREEN; };');
			expect(parsed[0]).with.deep.property('body[2]').to.be.an('object');
			expect(parsed[0]).with.deep.property('body[2].type','enum member');
			expect(parsed[0]).with.deep.property('body[2].name','GREEN');
		});
	});
	
	describe('class definition', function() {
			
		describe('empty object', function(){
			function testEmptyClassDefinition(parsed,className){
				expect(parsed[0]).to.have.all.keys('type','id','body','stereotype');

				expect(parsed[0]).to.have.property('id',className);
				expect(parsed[0]).to.have.property('type','class');
				expect(parsed[0]).to.have.property('body').that.is.null; 
				// expect(parsed[0]).to.have.property('stereotype').that.is.undefined; 
			}
			it('name only', function() {
				var parsed = parser.parse('class foo');
				
				testIsSingleStatment(parsed);
				testEmptyClassDefinition(parsed,'foo');
			});
			
			it('name with namespace', function(){
				var parsed = parser.parse('class baz.foo');
				
				testIsSingleStatment(parsed);
				testEmptyClassDefinition(parsed,'baz.foo');
			});
			
			it('name with namespce and stereotype', function(){
				var parsed = parser.parse('class baz.foo<<table>>');
			
				testIsSingleStatment(parsed);
				testEmptyClassDefinition(parsed,'baz.foo');

				expect(parsed[0]).to.have.property('stereotype')
					.to.be.an('array')
						.to.deep.equal([{name:'table',spot:null}]);
			});
		});
		
		describe('single element body', function(){
		
			function testClassDefinition(parsed,className){
				expect(parsed[0]).to.have.all.keys('type','id','body','stereotype');

				expect(parsed[0]).to.have.property('id',className);
				expect(parsed[0]).to.have.property('type','class');
				expect(parsed[0]).to.have.property('body').that.is.an('array').that.has.length(1); 
				// expect(parsed[0]).to.have.property('stereotype').that.is.undefined; 
			}
			
			it('scalar property', function(){
				var parsed = parser.parse('class baz.foo { id: int}');

				testIsSingleStatment(parsed);
				testClassDefinition(parsed,'baz.foo');
							
				// console.log(require('util').inspect(foo[0], {colors: true}));
				
				expect(parsed[0].body[0]).to.have.all.keys('attributes','data_type','name','scope','stereotype','type');
				
				expect(parsed[0].body[0]).to.have.property('type','property');
				expect(parsed[0].body[0]).to.have.property('name','id');
				expect(parsed[0].body[0]).to.have.property('data_type','int');
				expect(parsed[0].body[0]).to.have.property('attributes').that.is.null;
				expect(parsed[0].body[0]).to.have.property('stereotype').that.is.null;
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
			
			it('method', function(){
				var parsed = parser.parse('class baz.foo { void someMethod() }'); 

				testIsSingleStatment(parsed);
				testClassDefinition(parsed,'baz.foo');
				
				expect(parsed[0].body[0]).to.have.all.keys('data_type','name','scope','type');
				
				expect(parsed[0].body[0]).to.have.property('type','method');
				expect(parsed[0].body[0]).to.have.property('name','someMethod');
				expect(parsed[0].body[0]).to.have.property('data_type','void');
			});
			
			it('stereotyped property', function(){
				var parsed = parser.parse('class baz.foo { id: int <<PK,SK>>}');
				
				testIsSingleStatment(parsed);
				testClassDefinition(parsed,'baz.foo');
				
				expect(parsed[0].body[0]).to.have.all.keys('attributes','data_type','name','scope','stereotype','type');
				
				expect(parsed[0].body[0]).to.have.property('type','property');
				expect(parsed[0].body[0]).to.have.property('name','id');
				expect(parsed[0].body[0]).to.have.property('data_type','int');
				expect(parsed[0].body[0]).to.have.property('attributes').that.is.null;
				expect(parsed[0].body[0]).to.have.property('stereotype').that.is.an('array');
				
				expect(parsed[0].body[0].stereotype[1]).to.have.property('name','SK');
			});
			
			it('array property', function(){
				var parsed = parser.parse('class baz.foo { meh: char[254] }');
				
				testIsSingleStatment(parsed);
				testClassDefinition(parsed,'baz.foo');
					//.to.have.deep.property('body[0]')
					//	.to.have.all.keys('attributes','data_type','name','scope','stereotype','type');
				
				expect(parsed[0].body[0]).to.have.all.keys('attributes','data_type','name','scope','stereotype','type');
				
				expect(parsed[0].body[0]).to.have.property('type','property');
				expect(parsed[0].body[0]).to.have.property('name','meh');
				expect(parsed[0].body[0]).to.have.property('attributes').that.is.null;
				expect(parsed[0].body[0]).to.have.property('data_type')
					.to.be.an('object')
					.to.have.all.keys('type','basetype','size');
				
				expect(parsed[0].body[0].data_type).to.have.property('type','array');
				expect(parsed[0].body[0].data_type).to.have.property('basetype','char');
				expect(parsed[0].body[0].data_type).to.have.property('size','254');

			});
			
			it('scalar property with attribute', function(){
				var parsed = parser.parse('class baz.foo { meh: int {NULL} }');
				
				testIsSingleStatment(parsed);
				testClassDefinition(parsed,'baz.foo');
					//.to.have.deep.property('body[0]')
					//	.to.have.all.keys('attributes','data_type','name','scope','stereotype','type');
				
				expect(parsed[0].body[0]).to.have.all.keys('attributes','data_type','name','scope','stereotype','type');
				
				expect(parsed[0].body[0]).to.have.property('type','property');
				expect(parsed[0].body[0]).to.have.property('name','meh');			
				expect(parsed[0].body[0]).to.have.property('data_type','int')
				expect(parsed[0].body[0]).to.have.property('attributes','NULL');

			});
			
			it('not-nullable property', function(){
				var parsed = parser.parse('class baz.foo { meh: int {NOT NULL} }');
				
				testIsSingleStatment(parsed);
				testClassDefinition(parsed,'baz.foo');
					//.to.have.deep.property('body[0]')
					//	.to.have.all.keys('attributes','data_type','name','scope','stereotype','type');
				
				expect(parsed[0].body[0]).to.have.all.keys('attributes','data_type','name','scope','stereotype','type');
				
				expect(parsed[0].body[0]).to.have.property('type','property');
				expect(parsed[0].body[0]).to.have.property('name','meh');			
				expect(parsed[0].body[0]).to.have.property('data_type','int')
				expect(parsed[0].body[0]).to.have.property('attributes','NOT NULL');
			});
			
			it('stereotype property with attribute body', function(){
				var parsed = parser.parse('class baz.foo { meh: int {NULL} <<FK>> }');
				
				testIsSingleStatment(parsed);
				testClassDefinition(parsed,'baz.foo');
				
					//.to.have.deep.property('body[0]')
					//	.to.have.all.keys('attributes','data_type','name','scope','stereotype','type');
				
				expect(parsed[0].body[0]).to.have.all.keys('attributes','data_type','name','scope','stereotype','type');
				
				expect(parsed[0].body[0]).to.have.property('type','property');
				expect(parsed[0].body[0]).to.have.property('name','meh');			
				expect(parsed[0].body[0]).to.have.property('data_type','int')
				expect(parsed[0].body[0]).to.have.property('attributes','NULL');
				expect(parsed[0].body[0]).to.have.property('stereotype')
					.to.be.an('array')
					.to.deep.equal([{name:'FK',spot:null}]);

			});
		});
		
		describe('Should parse full class', function() {
			var parsed;
			before(function(){
				var text = 'class baz.foo<<table>>{ \n'
							+'id: int <<PK,SK>> \n'
							+'some_other_table_id: int <<FK>> \n'
							+'property_idx: tinyint \n'
							+'property_rule_id: int {null} <<FK>> \n'
							+'property_class_id: int <<FK>> \n'
							+'property_name: string \n'
							+'property_value: string \n'
							+'} \n';
				parsed = parser.parse(text);
			});
			
			it('as single statment', function(){
				testIsSingleStatment(parsed);
			});
			
			it('with class definition', function(){
				expect(parsed[0]).to.have.all.keys('type','id','body','stereotype');

				expect(parsed[0]).to.have.property('id','baz.foo');
				expect(parsed[0]).to.have.property('type','class');
				expect(parsed[0]).to.have.property('body').that.is.an('array').that.has.length(7); 
				// expect(parsed[0]).to.have.property('stereotype').that.is.undefined; 
			});
			
			it('with class stereotype', function(){
				expect(parsed[0].stereotype).to.deep.equal([{name:'table',spot:null}]);
			});
			
			it('with multiple stereotype property', function(){
				expect(parsed[0]).with.deep.property('body[0].stereotype')
					.that.is.an('array').that.deep.equals([{name:'PK',spot:null},{name:'SK',spot:null}]);
				expect(parsed[0]).with.deep.property('body[0].attributes').that.is.null;
			});
			
			it('with stereotype and attributer on property', function(){
				expect(parsed[0]).with.deep.property('body[3].stereotype')
					.that.is.an('array').that.deep.equals([{name:'FK',spot:null}]);
				expect(parsed[0]).with.deep.property('body[3].attributes','null');
			})
		});
	});
	
});// end class diagram tests

