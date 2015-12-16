var expect =  require('chai').expect;
var fs = require('fs');
var PEG = require('pegjs');

describe('PlantUML Preprocessor Commands', function() {

	var	parser;
	
	before(function(){
		var grammar;
		grammar = fs.readFileSync('./src/PlantUML.pegjs', 'utf8');
		parser = PEG.buildParser(grammar);
	});
	
	describe.skip('Include', function(){
		it('local file', function(){
			var parsed = parser.parse('@startuml; !include foo.txt; @enduml');
		});
		
		it('local file subsection', function(){
			var parsed = parser.parse('@startuml; !include foo.txt!1; @enduml');
		});
		
		it('url file', function(){
			var parsed = parser.parse('!includeurl http://localhost/foo.txt; @enduml');
		});
	});
	
	describe('constant definitions', function(){
		
		it('simple replacement', function(){
			var parsed = parser.parse('@startuml; !define table Database Table\n @enduml');
		});
		
		it('full stereotype', function(){
			var parsed = parser.parse('@startuml; !define table (T,PowderBlue)Database Table\n @enduml');
		});
		
		it('tags', function(){
			var parsed = parser.parse('@startuml; !define PK <color:orange>  <&key></color>\n @enduml');
		});
		
	});	// end constant definitions 
	
	describe.skip('Formatting Elements', function(){
		describe('show/hide document elements', function(){
		
			it('for empty fields', function(){
				var parsed = parser.parse('@startuml; hide empty fields; @enduml' );
				var parsed = parser.parse('@startuml; hide empty attributes; @enduml'); 
			});
			
			it('for empty methods', function(){
				var parsed = parser.parse('@startuml; hide empty methods; @enduml' );
			});
			
			it('which will hide fields, even if they are described', function(){
				var parsed = parser.parse('@startuml; hide fields; @enduml');
				var parsed = parser.parse('@startuml; hide attributes; @enduml' );
			});
			
			it('wich will hide methods, even if they are described', function(){
				var parsed = parser.parse('@startuml; hide methods; @enduml' );
			});
			
			it('wich will hide fields and methods, even if they are described', function(){
				var parsed = parser.parse('@startuml; hide members; @enduml' );
			});
			
			it('for the circled character in front of class name', function(){
				var parsed = parser.parse('@startuml; hide circle; @enduml' );
			});
			
			it('for the stereotype', function(){
				var parsed = parser.parse('@startuml; hide stereotype; @enduml' );
			});
			
			it('for all classes', function(){
				var parsed = parser.parse('@startuml; hide class; @enduml');
			 });
			
			it('for all interfaces', function(){
				var parsed = parser.parse('@startuml; hide interface; @enduml');
			});
			
			it('for all enums', function(){
				var parsed = parser.parse('@startuml; hide enum; @enduml' );
			});
			
			it('for classes which are stereotyped with foo1', function(){
				var parsed = parser.parse('@startuml; hide <<foo1>>; @enduml' );
			});
			
			it('an existing class name', function(){
				var parsed = parser.parse('@startuml; hide someClass; @enduml' );
			});

		});
		
		describe.skip('set redering ', function(){
			it('single skinparam', function(){
				var parsed = parser.parse('@startuml; skinparam classFontColor red; @enduml');
			});
			
			it('multiple skinparam', function(){
				var parsed = parser.parse('@startuml; skinparam class{\nFontColor red\nFontSize 10\nFontName Anpex\n}; @enduml');
			});
			
			it('invalid skinparam', function(){
				expect(parser.parse('@startuml; skinparam stateFontColor red; @enduml')).to.throw(parser.SyntaxError);
			});
			
			it('invalid skinparam group', function(){
				expect(parser.parse('@startuml; skinparam state{\nFontColor red}; @enduml')).to.throw(parser.SyntaxError);
			});
		});
		
	});
});// end annotation diagram