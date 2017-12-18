CREATE DATABASE IF NOT EXISTS whitehat1;
ALTER DATABASE whitehat1 CHARACTER SET utf8 COLLATE utf8_unicode_ci;
CREATE USER IF NOT EXISTS 'whitehat1'@'localhost' IDENTIFIED BY '7156823d1e463e1813a8da4786f06b7659a34ad539262cade785484dddcb090b';
GRANT SELECT, INSERT ON `whitehat1`.* TO `whitehat1`@`localhost`;

USE whitehat1;

CREATE TABLE IF NOT EXISTS `users` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`username` varchar(255) DEFAULT NULL,
	`password` varchar(255) DEFAULT NULL,
	PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `posts` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`user_id` int(11) DEFAULT NULL,
	`title` text,
	`content` text,
	PRIMARY KEY (`id`),
	FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
);

CREATE TABLE IF NOT EXISTS `comments` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`user_id` int(11) DEFAULT NULL,
	`post_id` int(11) DEFAULT NULL,
	`title` text,
	`content` text,
	PRIMARY KEY (`id`),
	FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
	FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`)
);

INSERT INTO `users` (id, username, password) VALUES (1, "admin", "admin"), (2, "linerd0196", "buzzzzzzzzz"), (3, "lead ninja", "buzzzzzzzzzz");
INSERT INTO `posts` (id, user_id, title, content) VALUES (1, 2, "London is red, bitches !!!", "It's just red");
INSERT INTO `posts` (id, user_id, title, content) VALUES (2, 1, "Hack me please", "This page is impregnable. HAHAHAHAHA");
INSERT INTO `posts` (id, user_id, title, content) VALUES (3, 3, "GET OUT OF MY WAY", "HAHAHA");
INSERT INTO `comments` (user_id, post_id, content) VALUES (1, 1, "COYG");
INSERT INTO `comments` (user_id, post_id, content) VALUES (2, 2, "Give me some good fellows and some drinks and I'll impregnate the bitch :))");
INSERT INTO `comments` (user_id, post_id, content) VALUES (1, 3, "Shut up please or I'll ban you");
