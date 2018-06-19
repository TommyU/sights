-- mysql ddl statements

create database sights;

CREATE TABLE IF NOT EXISTS `sights`.`video_tab` (
	`id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
	`ctime` INT UNSIGNED NOT NULL,
	`last_downloaded_time` INT UNSIGNED ,
	`downloaded_times` INT UNSIGNED NOT NULL DEFAULT 1,
	`deleted_time` INT UNSIGNED ,
	`keyword` VARCHAR(250) NOT NULL,
	`youtube_url` BLOB NOT NULL,
	`youtube_url_hash` VARCHAR(64) NOT NULL,
	`video_name` VARCHAR(512) NOT NULL,
	`video_size` INT UNSIGNED NULL,
	`stored_path` VARCHAR(1024) ,
	`is_deleted` TINYINT UNSIGNED NOT NULL DEFAULT 0,
	PRIMARY KEY (`id`),
	UNIQUE INDEX idx_video_hash (`youtube_url_hash`),
	INDEX idx_dtime_status (`last_downloaded_time`, `is_deleted`)
)
COLLATE='utf8_unicode_ci'
ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `sights`.`admin` (
	`id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
	`ctime` INT UNSIGNED NOT NULL,
	`account` VARCHAR(64) NOT NULL,
	`password` VARCHAR(32) NOT NULL,
	`is_super_admin` INT UNSIGNED NULL,
	`is_deleted` TINYINT UNSIGNED NOT NULL DEFAULT 0,
	PRIMARY KEY (`id`),
	UNIQUE INDEX idx_account (`account`)
)
COLLATE='utf8_unicode_ci'
ENGINE=InnoDB;

grant all privileges on sight.* to 'sights'@'127.0.0.1' identified by 'sights_pw';
grant all privileges on sight.* to 'sights'@'localhost' identified by 'sights_pw';

