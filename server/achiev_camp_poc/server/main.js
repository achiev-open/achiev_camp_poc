import { Meteor } from 'meteor/meteor';

Meteor.startup(() => {
  // code to run on server at startup
	console.log("Server started");
});

Accounts.validateNewUser((user) => {
	if (!SimpleSchema.RegEx.Email.test(user.emails[0].address)) {
		throw new Error("Email format is in valid");
	}
	new SimpleSchema({
		_id: { type: String },
		emails: { type: Array },
		'emails.$': { type: Object },
		'emails.$.address': { type: String },
		'emails.$.verified': { type: Boolean },
		createdAt: { type: Date },
		profile: { type: Object },
		'profile.name': { type: String },
		services: { type: Object, blackbox: true }
	}).validate(user);

	return true;
});

Meteor.methods({
	async "signup"(signUpData) {
		const user = {
			email: signUpData.email,
			password: signUpData.password,
			profile: {
				name: signUpData.name,
			}
		};

		try {
			await Accounts.createUser(user);
		} catch (err) {
			throw new Meteor.Error(400, err.message);
		}
	},
	"updateLocation"(x, y, direction) {
		Meteor.users.update({ _id: this.userId }, {
			$set: {
				location: { x, y, direction },
			}
		});
	}
});

// Meteor.publish("playerLocation", function () {
// 	return Meteor.users.find({ _id: this.userId }, { projection: { location: 1 } });
// });

Meteor.publish("onlinePlayers", function () {
	return Meteor.users.find({
		$or: [
			{ _id: this.userId },
			{ "status.online": true }
		]
	}, { projection: { profile: 1, location: 1, status: 1 } });
});
