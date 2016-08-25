"use strict";

var expect =  require('chai').expect;
var PEG = require('pegjs');
var parser = require('../lib/parser');

describe('PlantUML Diagram Annotations', function() {

	describe('Singleton Annotaitons', function(){
		it('header', function(){
			var parsed = parser.parse('@startuml\n Header My Project Docs endheader\n@enduml');
		});
		
		it('footer', function(){
			var parsed = parser.parse('@startuml\n footer Copyright 2014 Example, Inc. endfooter \n@enduml');
		});
		
		it('legend', function(){
			var text =  '@startuml\n '
				+'legend right\n'
				+'Primary Key - PK \n'
				+'Foreign Key - FK \n'
				+'Natural Key - NK \n'
				+'end legend \n'
				+'@enduml';
			var parsed = parser.parse(text);
		});
		
		it('title', function(){
			var parsed = parser.parse('@startuml\n title Biz.buz Diagram <<Physical Data Model>> \n@enduml');
		});
	});
	
	describe('Notes', function(){
		it('basic note', function(){
			var parsed = parser.parse('@startuml\n note: this is a simple note \n@enduml');
		});
	});

/*
note as n1
Assume column are {NOT NULL} and 
that indexes exist for all <<PK>> 
and <<FK>> columns
end note
*/
	
});// end annotation diagram
