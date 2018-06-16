-- mysql ddl statements

create database sights;

CREATE TABLE IF NOT EXISTS `sights`.`video_tab` (
	`id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
	`ctime` INT UNSIGNED NOT NULL,
	`last_downloaded_time` INT UNSIGNED NOT NULL,
	`deleted_time` INT UNSIGNED NOT NULL,
	`keyword` VARCHAR(250) NOT NULL,
	`youtube_url` BLOB NOT NULL,
	`video_name` VARCHAR(512) NOT NULL,
	`stored_path` VARCHAR(1024) NOT NULL,
	`is_deleted` TINYINT UNSIGNED NOT NULL DEFAULT 0,
	PRIMARY KEY (`id`),
	UNIQUE INDEX idx_keyword (`keyword`),
	INDEX idx_dtime_status (`last_downloaded_time`, `is_deleted`)
)
COLLATE='utf8_unicode_ci'
ENGINE=InnoDB;

grant all privileges on sight.* to 'sights'@'127.0.0.1' identified by 'sights_pw';

