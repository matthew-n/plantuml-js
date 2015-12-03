var expect =  require('chai').expect;
var fs = require('fs');
var PEG = require('pegjs');

describe.skip('PlantUML Activity Diagram - beta syntax', function() {

	var	parser;
	
	before(function(){
		var grammar;
		grammar = fs.readFileSync('./PlantUML.pegjs', 'utf8');
		parser = PEG.buildParser(grammar);
	});
	
	describe('parses basic document',function(){
			
		it('multi-line activity',function(){
			var parsed = parser.parse(':Hello world; \n :This is on defined on \n servral **line**;\n');
		});
		
		it('start and stop keywords',function(){
			var parsed = parser.parse('start\n:Hello World;\n:This is on defined on serval **lines**;\nstop');
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
				'start \n'+
				'if (Graphviz installed?) then (yes) \n'+
				':process all\ndiagrams; \n'+
				'else (no) \n'+
				':process only \n'+
				'__sequence__ and __activity__ diagrams; \n'+
				'endif \n'+
				'stop'
		});
		
		it('multiple branch multiple node', function(){
			var text = 
				'start \n'+
				'if (condition A) then (yes) \n'+
				'	:Text 1; \n'+
				'elseif (condition B) then (yes) \n'+
				'	:Text 2; \n'+
				'stop \n'+
				'elseif (condition C) then (yes) \n'+
				'	:Text 3; \n'+
				'elseif (condition D) then (yes) \n'+
				'	:Text 4; \n'+
				'else (nothing) \n'+
				'	:Text else; \n'+
				'endif \n'+
				'stop'

		});
		
		it('multiple branch multiple node', function(){
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
	
	describe('Looping', function(){
		it('Repeat', function(){
			var text = 
				'start \n'+
				'repeat \n'+
				':read data; \n'+
				':generate diagrams; \n'+
				'repeat while (more data?) \n'+
				'stop';

		});
		it('While', function(){
			var text = 
				'start \n'+
				'while(data availible?) \n'+
				':read data; \n'+
				':generate diagrams; \n'+
				'endwhile \n'+
				'stop';
		});
		
		it('label after while', function(){
			var text = 
				'while (check filesize ?) is (not empty) \n'+
				':read file; \n'+
				'endwhile (empty) \n'+
				':close file;';
		});
	});
	
	describe('Parallel Processing', function(){
		it('basic', function(){
			var text = 
				'start \n'+
				'if (multiprocessor?) then (yes)\n'+
				'fork\n'+
				':Treatment 1;\n'+
				'fork again\n'+
				':Treatment 2;\n'+
				'end fork\n'+
				'else (monoproc)\n'+
				':Treatment 1;\n'+
				':Treatment 2;\n'+
				'endif\n';
		});
		it('detach', function(){
			var text = 
				'start \n'+
				'if (multiprocessor?) then (yes)\n'+
				'fork\n'+
				':Treatment 1;\n'+
				'fork again\n'+
				':Treatment 2;\n'+
				'fork again\n'+
				':foo3;\n'+
				'detach\n'+
				'end fork\n'+
				'else (monoproc)\n'+
				':Treatment 1;\n'+
				':Treatment 2;\n'+
				'endif\n';
		});
		it('long fork', function(){
			var text = 
				'start \n'+
				'if (multiprocessor?) then (yes)\n'+
				'fork\n'+
				':Treatment 1;\n'+
				'fork again\n'+
				':Treatment 2;\n'+
				':foo3;\n'+
				'detach\n'+
				'end fork\n'+
				'else (monoproc)\n'+
				':Treatment 1;\n'+
				':Treatment 2;\n'+
				'endif\n';
		});

	});
	describe('Color decorations', function(){
		it('for Process', function(){
			var text = 
				'start \n'+
				':start progress; \n'+
				'#HotPink:reding configuration files \n'+
				'These files should edited at this point! \n'+
				'#AAAAAA:ending of the process;';
		});
		it('for Arrows', function(){
			var text = 
				':foo1; \n'+
				'-[#blue]-> \n'+
				':foo2; \n';
		});
	});
	describe('Grouping',function(){
		it('basic test', function(){
		var text = 
			'start \n'+
			'partition Initializetion {\n'+
			':read config file;\n'+
			':init internal variables;\n'+
			'} \n'+
			'partition Running {\n'+
			':wait for user interaction;\n'+
			':print information;\n'+
			'} \n'+
			'stop';
		});
	});
	describe('swimlanes',function(){
		it('basic definition', function(){
			var text = '|lane1|\nstart\n:fooA;\n|lane2|\n:fooB;\n|lane1|\nstop';	
		});
		it('allow color', function(){
			var text = '|lane1|\nstart\n:fooA;\n|#AntiqueWhite|lane2|\n:fooB;\n|lane1|\nstop';
		});
	});

	describe('Specification and Description Language (SDL)', function(){
		it('state', function(){
			var text = ':foo;';
		});
		it('Recive', function(){
			var text = ':input<';
		});
		it('Send', function(){
			var text = ':print>';
		});
		it('function call', function(){
			var text = ':func(x)|';
		});
		it('decision', function(){
			var text = ':i > 5}';
		});
		it('save state', function(){
			var test = ':foo/';
		});
		it('execute', function(){
			var text = 'i := i+1]';
		});
	});
});

