var expect =  require('chai').expect;
var fs = require('fs');
var PEG = require('pegjs');

describe.skip('PlantUML Activity Diagram - classic syntax', function() {

	var	parser;
	
	before(function(){
		var grammar;
		grammar = fs.readFileSync('./PlantUML.pegjs', 'utf8');
		parser = PEG.buildParser(grammar);
	});
	
	describe('parses basic document',function(){
		it('named source and destination',function(){
			var parsed = parser.parse('(*) --> "some activity" \n "some activity" --> (*)\n');
		});
		
		it('implicit source',function(){
			var parsed = parser.parse('(*) \n --> "some activity" \n --> (*)\n');
		});
	});
	
	describe('transistion arrorws', function(){
		it('can have lables',function(){
			var parsed = parser.parse('(*) \n --> "some activity" \n --> [you can put labels] "second activity"  \n --> (*)\n');
		});
		
		it('can have directions',function(){
			var parsed = parser.parse('(*) \n -up-> "some activity" \n -left-> "second activity"  \n -down-> (*)\n');
		});
	});
	
	describe('Conditionals', function(){
		it('single branch single node', function(){
			var text = 
				'(*) --> if "Some Test" then \n';
				'	-->[true] "activity 1" \n';
				'else \n';
				'	-->[false] "activity 2" \n';
				'endif \n';
		});
		
		it('single branch multiple node', function(){
			var text = 
				'(*) --> "Initialisation" \n'+
				'if "Some Test" then \n'+
				'	-->[true] "Some Activity" \n'+
				'	--> "Another activity" \n'+
				'	-right -> (*) \n'+
				'else  \n'+
				'	->[false] "Something else"  \n'+
				'	-->[Ending process] (*) \n'+
				'endif \n';
		});
	});
	
});