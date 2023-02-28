import { Meteor } from 'meteor/meteor';

Meteor.startup(() => {
  // code to run on server at startup
	console.log("Server started");
});

Meteor.methods({
	"hello"(name) {
		console.log(`Hello ${name}`);
		return `Hello ${name}`;
	}
});
