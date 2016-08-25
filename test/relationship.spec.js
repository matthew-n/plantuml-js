var expect =  require('chai').expect;
var fs = require('fs');
var PEG = require('pegjs');

describe('PlantUML Relationships', function() {

	var	parser;
	before(function(){
		var grammar = fs.readFileSync('./lib/plantuml-js.pegjs', 'utf8');
		parser = PEG.buildParser(grammar, { allowedStartRules: ["start"] });
	});

	describe('basic relationships', function(){
		
		describe('length 1', function(){
			it ('dashed', function(){
				var parsed = parser.parse('@startuml\n A - B;\n @enduml');
			});
			
			it('doted', function(){
				var parsed = parser.parse('@startuml\n A . B;\n @enduml');
			});
		});
		
		describe('length 2', function(){
			it ('dashed', function(){
				var parsed = parser.parse('@startuml\n A -- B;\n @enduml');
			});
			
			it('doted', function(){
				var parsed = parser.parse('@startuml\n A .. B;\n @enduml');
			});
		});
		
		describe('length 5', function(){
			it ('dashed', function(){
				var parsed = parser.parse('@startuml\n A ----- B;\n @enduml');
			});
			
			it('doted', function(){
				var parsed = parser.parse('@startuml\n A ..... B;\n @enduml');
			});
		});
		
	});
	
	describe('Realtionship types', function(){
		it('Extention', function(){
			var parsed = parser.parse('@startuml\n A -|> B;\n @enduml');
		});
		
		it('Composition', function(){
			var parsed = parser.parse('@startuml\n A -* B;\n @enduml');
		});
		
		it('Aggregation', function(){
			var parsed = parser.parse('@startuml\n A -o B;\n @enduml');
		});
		
		it('Arrowed', function(){
			var parsed = parser.parse('@startuml\n A -> B;\n @enduml');
		});
		
		it('Lollipop', function(){
			var parsed = parser.parse('@startuml\n A -() B;\n @enduml');
		});
	});
	
	describe('Cardinality values', function(){	
		it('single number left', function(){
			var parsed = parser.parse('@startuml\n A "1" -- B;\n @enduml');
		});
		
		it('single number right', function(){
			var parsed = parser.parse('@startuml\n A -- "1" B;\n @enduml');
		});
		
		it('single number both', function(){
			var parsed = parser.parse('@startuml\n A "1" -- "1" B;\n @enduml');
		});
		
		it('range number left', function(){
			var parsed = parser.parse('@startuml\n A "*..n" -- B;\n @enduml');
		});
		
		it('range number right', function(){
			var parsed = parser.parse('@startuml\n A -- "*..n" B;\n @enduml');
		});
		
		it('range number both', function(){
			var parsed = parser.parse('@startuml\n A "*..n" -- "*..n" B;\n @enduml');
		});
	});
	
	describe('Relationship label', function(){
		it('non literal', function(){
			var parsed = parser.parse('@startuml\n A - B: has some relation;\n @enduml');
		});
		
		it('literal string', function(){
			var parsed = parser.parse('@startuml\n A -> B: "has some symbols: -> class";\n @enduml');
		});
	});
	
	describe('Relationship label arrow', function(){
		it('point right', function(){
			var parsed = parser.parse('@startuml\n A - B: has some relation >;\n @enduml');
		});
		
		it('point left', function(){
			var parsed = parser.parse('@startuml\n A - B: has some relation <;\n @enduml');
		});
		
	});
	
}); // end relations