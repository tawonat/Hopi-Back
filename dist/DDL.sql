-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema hopi_hari_db
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `hopi_hari_db` ;

-- -----------------------------------------------------
-- Schema hopi_hari_db
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `hopi_hari_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
USE `hopi_hari_db` ;

-- -----------------------------------------------------
-- Table `hopi_hari_db`.`areas`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `hopi_hari_db`.`areas` ;

CREATE TABLE IF NOT EXISTS `hopi_hari_db`.`areas` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Table `hopi_hari_db`.`rides`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `hopi_hari_db`.`rides` ;

CREATE TABLE IF NOT EXISTS `hopi_hari_db`.`rides` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `waiting_time` INT NOT NULL,
  `status` VARCHAR(50) NOT NULL,
  `id_areas` INT NOT NULL,
  `image` VARCHAR(200) NULL,
  PRIMARY KEY (`id`, `id_areas`),
  INDEX `fk_rides_areas1_idx` (`id_areas` ASC) VISIBLE,
  CONSTRAINT `fk_rides_areas1`
    FOREIGN KEY (`id_areas`)
    REFERENCES `hopi_hari_db`.`areas` (`id`))
ENGINE = InnoDB
AUTO_INCREMENT = 8
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Table `hopi_hari_db`.`users`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `hopi_hari_db`.`users` ;

CREATE TABLE IF NOT EXISTS `hopi_hari_db`.`users` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(50) NOT NULL,
  `last_name` VARCHAR(50) NOT NULL,
  `email` VARCHAR(100) NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `birth_date` DATE NOT NULL,
  `phone` VARCHAR(20) NULL DEFAULT NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `email` (`email` ASC) VISIBLE)
ENGINE = InnoDB
AUTO_INCREMENT = 6
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Table `hopi_hari_db`.`lines`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `hopi_hari_db`.`lines` ;

CREATE TABLE IF NOT EXISTS `hopi_hari_db`.`lines` (
  `id_ride` INT NOT NULL,
  `id_user` INT NOT NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_ride`, `id_user`),
  INDEX `fk_rides_has_users_users1_idx` (`id_user` ASC) VISIBLE,
  INDEX `fk_rides_has_users_rides_idx` (`id_ride` ASC) VISIBLE,
  CONSTRAINT `fk_rides_has_users_rides`
    FOREIGN KEY (`id_ride`)
    REFERENCES `hopi_hari_db`.`rides` (`id`),
  CONSTRAINT `fk_rides_has_users_users1`
    FOREIGN KEY (`id_user`)
    REFERENCES `hopi_hari_db`.`users` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;


-- -----------------------------------------------------
-- Table `hopi_hari_db`.`notifications`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `hopi_hari_db`.`notifications` ;

CREATE TABLE IF NOT EXISTS `hopi_hari_db`.`notifications` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `description` VARCHAR(200) NOT NULL,
  `id_rides` INT NOT NULL,
  `id_user` INT NOT NULL,
  `status` TINYINT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_notifications_rides1_idx` (`id_rides` ASC) VISIBLE,
  INDEX `fk_notifications_users1_idx` (`id_user` ASC) VISIBLE,
  CONSTRAINT `fk_notifications_rides1`
    FOREIGN KEY (`id_rides`)
    REFERENCES `hopi_hari_db`.`rides` (`id`),
  CONSTRAINT `fk_notifications_users1`
    FOREIGN KEY (`id_user`)
    REFERENCES `hopi_hari_db`.`users` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_unicode_ci;

USE `hopi_hari_db`;

DELIMITER $$

USE `hopi_hari_db`$$
DROP TRIGGER IF EXISTS `hopi_hari_db`.`after_insert_lines` $$
USE `hopi_hari_db`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `hopi_hari_db`.`after_insert_lines`
AFTER INSERT ON `hopi_hari_db`.`lines`
FOR EACH ROW
BEGIN
    	DECLARE wait_time INT;
        DECLARE line_count INT;
        DECLARE total_wait INT;
                    
        SELECT waiting_time INTO wait_time
          FROM rides
		 WHERE id = NEW.id_ride;
            
		SELECT COUNT(id_user) INTO line_count
          FROM hopi_hari_db.lines
		 WHERE id_ride = NEW.id_ride;
                
         SET total_wait = wait_time * line_count;
         
         INSERT INTO notifications (description, id_rides, id_user, status)
		 VALUES (CONCAT(total_wait, " minuto(s) de espera para o brinquedo" ), NEW.id_ride, NEW.id_user, TRUE);
	END$$


DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;