var expect =  require('chai').expect;
var fs = require('fs');
var PEG = require('pegjs');

describe('PlantUML Annotation Diagram', function() {

	var	parser;
	
	before(function(){
		var grammar;
		grammar = fs.readFileSync('./PlantUML.pegjs', 'utf8');
		parser = PEG.buildParser(grammar);
	});
	
	describe('constant definitions', function(){
		
		it('simple replacement', function(){
			var parsed = parser.parse('!define table Database Table;');
		});
		
		it('full stereotype', function(){
			var parsed = parser.parse('!define table (T,PowderBlue)Database Table');
		});
		
		it('tags', function(){
			var parsed = parser.parse('!define PK <color:orange>  <&key></color>;');
		});
		
	});	// end constant definitions 
	
	describe('Formatting Elements', function(){
		describe('show/hide document elements', function(){
		
			it('for empty fields', function(){
				var parsed = parser.parse('hide empty fields' );
				var parsed = parser.parse('hide empty attributes'); 
			});
			
			it('for empty methods', function(){
				var parsed = parser.parse('hide empty methods' );
			});
			
			it('which will hide fields, even if they are described', function(){
				var parsed = parser.parse('hide fields');
				var parsed = parser.parse('hide attributes' );
			});
			
			it('wich will hide methods, even if they are described', function(){
				var parsed = parser.parse('hide methods' );
			});
			
			it('wich will hide fields and methods, even if they are described', function(){
				var parsed = parser.parse('hide members' );
			});
			
			it('for the circled character in front of class name', function(){
				var parsed = parser.parse('hide circle' );
			});
			
			it('for the stereotype', function(){
				var parsed = parser.parse('hide stereotype' );
			});
			
			it('for all classes', function(){
				var parsed = parser.parse('hide class');
			 });
			
			it('for all interfaces', function(){
				var parsed = parser.parse('hide interface');
			});
			
			it('for all enums', function(){
				var parsed = parser.parse('hide enum' );
			});
			
			it('for classes which are stereotyped with foo1', function(){
				var parsed = parser.parse('hide <<foo1>>' );
			});
			
			it('an existing class name', function(){
				var parsed = parser.parse('hide someClass' );
			});

		});
		
		describe.skip('set redering ', function(){
		});
	});
	
});// end annotation diagram