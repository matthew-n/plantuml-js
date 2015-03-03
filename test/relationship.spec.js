var expect =  require('chai').expect;
var fs = require('fs');
var PEG = require('pegjs');

describe('PlantUML Relationships', function() {

	var	parser;
	before(function(){
		var grammar;
		grammar = fs.readFileSync('./PlantUML.pegjs', 'utf8');
		parser = PEG.buildParser(grammar);
	});

	describe('basic relationships', function(){
		
		describe('length 1', function(){
			it ('dashed', function(){
				var parsed = parser.parse('A - B');
			});
			
			it('doted', function(){
				var parsed = parser.parse('A . B');
			});
		});
		
		describe('length 2', function(){
			it ('dashed', function(){
				var parsed = parser.parse('A -- B');
			});
			
			it('doted', function(){
				var parsed = parser.parse('A .. B');
			});
		});
		
		describe('length 5', function(){
			it ('dashed', function(){
				var parsed = parser.parse('A ----- B');
			});
			
			it('doted', function(){
				var parsed = parser.parse('A ..... B');
			});
		});
		
	});
	
	describe('Realtionship types', function(){
		it('Extention', function(){
			var parsed = parser.parse('A -|> B');
		});
		
		it('Composition', function(){
			var parsed = parser.parse('A -* B');
		});
		
		it('Agregation', function(){
			var parsed = parser.parse('A -o B');
		});
		
		it('Arrowed', function(){
			var parsed = parser.parse('A -> B');
		});
		
		it('Lollipop', function(){
			var parsed = parser.parse('A -() B');
		});
	});
	
	describe('Carnality values', function(){	
		it('single number left', function(){
			var parsed = parser.parse('A "1" -- B');
		});
		
		it('single number right', function(){
			var parsed = parser.parse('A -- "1" B');
		});
		
		it('single number both', function(){
			var parsed = parser.parse('A "1" -- "1" B');
		});
		
		it('range number left', function(){
			var parsed = parser.parse('A "*..n" -- B');
		});
		
		it('range number right', function(){
			var parsed = parser.parse('A -- "*..n" B');
		});
		
		it('range number both', function(){
			var parsed = parser.parse('A "*..n" -- "*..n" B');
		});
	});
	
	describe('Relationship label', function(){
		it('non literal', function(){
			var parsed = parser.parse('A - B: has some relation \n');
		});
		
		it('literal string', function(){
			var parsed = parser.parse('A -> B: "has some symbols: -> class" \n');
		});
	});
	
	describe('Relationship label arrow', function(){
		it('point right', function(){
			var parsed = parser.parse('A - B: has some relation > \n');
		});
		
		it('point left', function(){
			var parsed = parser.parse('A - B: has some relation < \n');
		});
	});
	
}); // end relations