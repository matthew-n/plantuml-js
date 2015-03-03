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
	
	describe('enum definition', function() {
		it('empty deffintion', function (){
			var parsed = parser.parse('enum bar;');
			
			expect(parsed[0]).that.is.an('object');

			expect(parsed[0]).to.have.all.keys('type','id','body');

			expect(parsed[0]).to.have.property('type','enum');
			expect(parsed[0]).to.have.property('id','bar');
			expect(parsed[0]).to.have.property('body').that.is.undefined;
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
			it('name only', function() {
				var parsed = parser.parse('class foo');
				
				expect(parsed).that.is.an('array');
				expect(parsed[0]).that.is.an('object');

				expect(parsed[0]).to.have.all.keys('type','id','body','stereotype');

				expect(parsed[0]).to.have.property('id','foo');
				expect(parsed[0]).to.have.property('type','class');
				expect(parsed[0]).to.have.property('stereotype').that.is.undefined;
				expect(parsed[0]).to.have.property('body').that.is.undefined;
			});
			
			it('name with namespace', function(){
				var parsed = parser.parse('class baz.foo');
				
				expect(parsed[0]).to.have.all.keys('type','id','body','stereotype');

				expect(parsed[0]).to.have.property('id','baz.foo');
				expect(parsed[0]).to.have.property('type','class');
				expect(parsed[0]).to.have.property('stereotype').that.is.undefined;
				expect(parsed[0]) .to.have.property('body').that.is.undefined;
			});
			
			it('name with namespce and stereotype', function(){
				var parsed = parser.parse('class baz.foo<<table>>');
			
				expect(parsed[0]).to.have.all.keys('type','id','body','stereotype');

				expect(parsed[0]).to.have.property('id','baz.foo');
				expect(parsed[0]).to.have.property('type','class');
				expect(parsed[0]).to.have.property('body').that.is.undefined;
				
				expect(parsed[0]).to.have.property('stereotype')
					.to.be.an('array')
						.to.deep.equal([{name:'table',spot:undefined}]);
			});
		});
		
		describe('single element body', function(){
			it('scalar property', function(){
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
				expect(parsed[0].body[0]).to.have.property('attributes').that.is.undefined;
				expect(parsed[0].body[0]).to.have.property('stereotype').that.is.undefined;
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

				expect(parsed[0]).to.have.all.keys('type','id','body','stereotype');

				expect(parsed[0]).to.have.property('id','baz.foo');
				expect(parsed[0]).to.have.property('type','class');
				expect(parsed[0]).to.have.property('stereotype').that.is.undefined;
				expect(parsed[0]).to.have.property('body').that.is.an('array');
				
				expect(parsed[0].body[0]).to.have.all.keys('data_type','name','scope','type');
				
				expect(parsed[0].body[0]).to.have.property('type','method');
				expect(parsed[0].body[0]).to.have.property('name','someMethod');
				expect(parsed[0].body[0]).to.have.property('data_type','void');
			});
			
			it('stereotyped property', function(){
				var parsed = parser.parse('class baz.foo { id: int <<PK,SK>>}');
				
				expect(parsed[0]).to.have.all.keys('type','id','body','stereotype');

				expect(parsed[0]).to.have.property('id','baz.foo');
				expect(parsed[0]).to.have.property('type','class');
				expect(parsed[0]).to.have.property('stereotype').that.is.undefined;
				expect(parsed[0]).to.have.property('body').that.is.an('array');
				
				expect(parsed[0].body[0]).to.have.all.keys('attributes','data_type','name','scope','stereotype','type');
				
				expect(parsed[0].body[0]).to.have.property('type','property');
				expect(parsed[0].body[0]).to.have.property('name','id');
				expect(parsed[0].body[0]).to.have.property('data_type','int');
				expect(parsed[0].body[0]).to.have.property('attributes').that.is.undefined;
				expect(parsed[0].body[0]).to.have.property('stereotype').that.is.an('array');
				
				expect(parsed[0].body[0].stereotype[1]).to.have.property('name','SK');
			});
			
			it('array property', function(){
				var parsed = parser.parse('class baz.foo { meh: char[254] }');
				
				expect(parsed[0]).to.have.all.keys('type','id','body','stereotype');

				expect(parsed[0]).to.have.property('id','baz.foo');
				expect(parsed[0]).to.have.property('type','class');
				expect(parsed[0]).to.have.property('stereotype').that.is.undefined;
				expect(parsed[0]).to.have.property('body').that.is.an('array')
					//.to.have.deep.property('body[0]')
					//	.to.have.all.keys('attributes','data_type','name','scope','stereotype','type');
				
				expect(parsed[0].body[0]).to.have.all.keys('attributes','data_type','name','scope','stereotype','type');
				
				expect(parsed[0].body[0]).to.have.property('type','property');
				expect(parsed[0].body[0]).to.have.property('name','meh');
				expect(parsed[0].body[0]).to.have.property('attributes').that.is.undefined;
				expect(parsed[0].body[0]).to.have.property('data_type')
					.to.be.an('object')
					.to.have.all.keys('type','basetype','size');
				
				expect(parsed[0].body[0].data_type).to.have.property('type','array');
				expect(parsed[0].body[0].data_type).to.have.property('basetype','char');
				expect(parsed[0].body[0].data_type).to.have.property('size','254');

			});
			
			it('scalar property with attribute', function(){
				var parsed = parser.parse('class baz.foo { meh: int {NULL} }');

				expect(parsed[0]).to.have.all.keys('type','id','body','stereotype');

				expect(parsed[0]).to.have.property('id','baz.foo');
				expect(parsed[0]).to.have.property('type','class');
				expect(parsed[0]).to.have.property('stereotype').that.is.undefined;
				expect(parsed[0]).to.have.property('body').that.is.an('array');
					//.to.have.deep.property('body[0]')
					//	.to.have.all.keys('attributes','data_type','name','scope','stereotype','type');
				
				expect(parsed[0].body[0]).to.have.all.keys('attributes','data_type','name','scope','stereotype','type');
				
				expect(parsed[0].body[0]).to.have.property('type','property');
				expect(parsed[0].body[0]).to.have.property('name','meh');			
				expect(parsed[0].body[0]).to.have.property('data_type','int')
				expect(parsed[0].body[0]).to.have.property('attributes')
					.to.be.an('array')
					.to.deep.equal(['NULL']);

			});
			
			it('not-nullable property', function(){
				var parsed = parser.parse('class baz.foo { meh: int {NOT NULL} }');
				
				expect(parsed[0]).to.have.all.keys('type','id','body','stereotype');

				expect(parsed[0]).to.have.property('id','baz.foo');
				expect(parsed[0]).to.have.property('type','class');
				expect(parsed[0]).to.have.property('stereotype').that.is.undefined;
				expect(parsed[0]).to.have.property('body').that.is.an('array');
					//.to.have.deep.property('body[0]')
					//	.to.have.all.keys('attributes','data_type','name','scope','stereotype','type');
				
				expect(parsed[0].body[0]).to.have.all.keys('attributes','data_type','name','scope','stereotype','type');
				
				expect(parsed[0].body[0]).to.have.property('type','property');
				expect(parsed[0].body[0]).to.have.property('name','meh');			
				expect(parsed[0].body[0]).to.have.property('data_type','int')
				expect(parsed[0].body[0]).to.have.property('attributes')
					.to.be.an('array')
					.to.deep.equal(['NOT NULL']);
			});
			
			it('stereotype property with attribute body', function(){
				var parsed = parser.parse('class baz.foo { meh: int {NULL} <<FK>> }');
				
				expect(parsed[0]).to.have.all.keys('type','id','body','stereotype');

				expect(parsed[0]).to.have.property('id','baz.foo');
				expect(parsed[0]).to.have.property('type','class');
				expect(parsed[0]).to.have.property('stereotype').that.is.undefined;
				expect(parsed[0]).to.have.property('body').that.is.an('array');
					//.to.have.deep.property('body[0]')
					//	.to.have.all.keys('attributes','data_type','name','scope','stereotype','type');
				
				expect(parsed[0].body[0]).to.have.all.keys('attributes','data_type','name','scope','stereotype','type');
				
				expect(parsed[0].body[0]).to.have.property('type','property');
				expect(parsed[0].body[0]).to.have.property('name','meh');			
				expect(parsed[0].body[0]).to.have.property('data_type','int')
				expect(parsed[0].body[0]).to.have.property('attributes')
					.to.be.an('array')
					.to.deep.equal(['NULL']);
				expect(parsed[0].body[0]).to.have.property('stereotype')
					.to.be.an('array')
					.to.deep.equal([{name:'FK',spot:undefined}]);

			});
		});
		
		describe('Should parse full class', function() {
			it('Should parse full class', function() {
				var text = 'class baz.foo<<table>>{ \n'
							+'id: int <<PK,SK>> \n'
							+'some_other_table_id: int <<FK>> \n'
							+'property_idx: tinyint \n'
							+'property_rule_id: int {null} <<FK>> \n'
							+'property_class_id: int <<FK>> \n'
							+'property_name: string \n'
							+'property_value: string \n'
							+'} \n';
				var parsed = parser.parse(text);
				
				expect(parsed[0]).to.have.all.keys('type','id','body','stereotype');

				expect(parsed[0]).to.have.property('id','baz.foo');
				expect(parsed[0]).to.have.property('type','class');
				expect(parsed[0]).to.have.property('stereotype')
					.to.be.an('array')
						.to.deep.equal([{name:'table',spot:undefined}]);
				
				expect(parsed[0]).to.have.property('body')
					.that.is.an('array')
					.to.have.length(7);
					
				expect(parsed[0]).with.deep.property('body[0].stereotype')
					.that.is.an('array').to.have.length(2);
				expect(parsed[0]).with.deep.property('body[0].attributes').that.is.undefined;
					
				expect(parsed[0]).with.deep.property('body[1].stereotype')
					.that.is.an('array').to.have.length(1);
				expect(parsed[0]).with.deep.property('body[1].attributes').that.is.undefined;
				
				expect(parsed[0]).with.deep.property('body[3].attributes')
					.that.is.an('array')
					.that.deep.equals( ['null']);
			});
		});
	});
	
});// end class diagram tests

