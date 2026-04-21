-- MySQL dump 10.13  Distrib 8.0.45, for macos15 (x86_64)
--
-- Host: localhost    Database: user_management
-- ------------------------------------------------------
-- Server version	9.6.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ 'fbde4584-2971-11f1-b088-86f64162279b:1-609';

--
-- Table structure for table `alumni`
--

DROP TABLE IF EXISTS `alumni`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `alumni` (
  `alumni_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `grad_year` int DEFAULT NULL,
  `position` varchar(100) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `occupation` varchar(100) DEFAULT NULL,
  `donation_status` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`alumni_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `alumni`
--

LOCK TABLES `alumni` WRITE;
/*!40000 ALTER TABLE `alumni` DISABLE KEYS */;
INSERT INTO `alumni` VALUES (1,'Ethan Morales','ethan.morales@umd.edu',2022,'Forward','301-555-1122','Data Analyst','Donated'),(2,'Ryan Patel','ryan.patel@umd.edu',2021,'Defense','301-555-2233','Consultant','Donated'),(3,'Noah Kim','noah.kim@umd.edu',2020,'Goalie','301-555-3344','Software Engineer','Donated'),(4,'Lucas Bennett','lucas.bennett@umd.edu',2019,'Forward','301-555-4455','Sales Manager','Has Not Donated'),(5,'Daniel Cruz','daniel.cruz@umd.edu',2018,'Defense','301-555-5566','Project Coordinator','Has Not Donated'),(6,'Tyler Nguyen','tyler.nguyen.alum@gmail.com',2023,'Forward','301-555-6677','Financial Analyst','Donated'),(7,'Jordan Brooks','jordan.brooks.alum@gmail.com',2022,'Defense','301-555-7788','Marketing Manager','Donated'),(8,'Marcus Webb','marcus.webb.alum@gmail.com',2021,'Forward','301-555-8899','Product Manager','Has Not Donated'),(9,'Sean Gallagher','sean.gallagher.alum@gmail.com',2020,'Goalie','301-555-9900','Physician Assistant','Donated'),(10,'Will Thornton','will.thornton.alum@gmail.com',2019,'Forward','301-555-0011','Attorney','Donated'),(11,'Patrick Doyle','patrick.doyle.alum@gmail.com',2018,'Defense','301-555-1234','Civil Engineer','Has Not Donated'),(12,'Alex Rivera','alex.rivera.alum@gmail.com',2017,'Forward','301-555-2345','Investment Banker','Donated'),(13,'Sam Kowalski','sam.kowalski.alum@gmail.com',2016,'Defense','301-555-3456','High School Coach','Donated'),(14,'Brian Foster','brian.foster.alum@gmail.com',2015,'Goalie','301-555-4567','Physical Therapist','Has Not Donated'),(15,'Colin Murphy','colin.murphy.alum@gmail.com',2023,'Defense','301-555-5678','Accountant','Donated');
/*!40000 ALTER TABLE `alumni` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `donations`
--

DROP TABLE IF EXISTS `donations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `donations` (
  `donation_id` int NOT NULL AUTO_INCREMENT,
  `alumni_id` int NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `donation_date` date NOT NULL,
  `message` text,
  PRIMARY KEY (`donation_id`),
  KEY `alumni_id` (`alumni_id`),
  CONSTRAINT `donations_ibfk_1` FOREIGN KEY (`alumni_id`) REFERENCES `alumni` (`alumni_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `donations`
--

LOCK TABLES `donations` WRITE;
/*!40000 ALTER TABLE `donations` DISABLE KEYS */;
INSERT INTO `donations` VALUES (1,1,1500.00,'2026-03-28','Happy to support the team. Go Terps!'),(2,2,2000.00,'2026-03-29','Proud alum donation. Keep up the great work.'),(3,3,750.00,'2026-03-30','Keep it going! Best season in years.'),(4,6,1000.00,'2026-02-10','Glad to give back. Go Terps!'),(5,7,500.00,'2026-02-15','Small contribution but big support from me!'),(6,9,3000.00,'2026-01-20','Alumni game donation - hope to see everyone there.'),(7,10,1500.00,'2026-01-25','Always proud to support UMD hockey.'),(8,12,2500.00,'2026-03-05','Keep building the program!'),(9,13,800.00,'2026-03-10','Great memories from my time on the team.'),(10,15,600.00,'2026-04-01','First time donating - plan to keep it up!');
/*!40000 ALTER TABLE `donations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `equipment_orders`
--

DROP TABLE IF EXISTS `equipment_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `equipment_orders` (
  `order_id` int NOT NULL AUTO_INCREMENT,
  `item_id` int NOT NULL,
  `supplier_user_id` int NOT NULL,
  `quantity` int NOT NULL,
  `order_status` enum('New Order','In Progress','Shipped','Received','Cancelled') NOT NULL DEFAULT 'New Order',
  `order_date` date DEFAULT NULL,
  `estimated_delivery_date` date DEFAULT NULL,
  `total_cost` decimal(10,2) DEFAULT NULL,
  `customer_notes` varchar(255) DEFAULT NULL,
  `vendor_notes` varchar(255) DEFAULT NULL,
  `received_to_inventory` tinyint(1) NOT NULL DEFAULT '0',
  `created_by_user_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`order_id`),
  KEY `item_id` (`item_id`),
  KEY `created_by_user_id` (`created_by_user_id`),
  KEY `idx_equipment_orders_status` (`order_status`),
  KEY `idx_equipment_orders_supplier` (`supplier_user_id`),
  CONSTRAINT `equipment_orders_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `inventory_items` (`item_id`) ON DELETE CASCADE,
  CONSTRAINT `equipment_orders_ibfk_2` FOREIGN KEY (`supplier_user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `equipment_orders_ibfk_3` FOREIGN KEY (`created_by_user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `equipment_orders`
--

LOCK TABLES `equipment_orders` WRITE;
/*!40000 ALTER TABLE `equipment_orders` DISABLE KEYS */;
INSERT INTO `equipment_orders` VALUES (1,3,4,8,'New Order','2026-04-10',NULL,NULL,'Need before next away game.',NULL,0,1,'2026-04-20 22:18:05'),(2,1,4,4,'In Progress','2026-04-08','2026-04-18',359.96,'Match current helmet model.','Awaiting final shipping pickup.',0,1,'2026-04-20 22:18:05'),(3,2,4,15,'Received','2026-04-01','2026-04-07',975.00,'Practice jersey refresh.','Delivered and signed for.',1,1,'2026-04-20 22:18:05'),(4,12,4,6,'New Order','2026-04-12',NULL,NULL,'Urgently needed - completely out.',NULL,0,1,'2026-04-20 22:18:05'),(5,8,16,10,'Shipped','2026-03-28','2026-04-05',280.00,'Standard replacement blades.','Shipped via UPS ground.',0,1,'2026-04-20 22:18:05'),(6,6,16,2,'Received','2026-03-15','2026-03-22',640.00,'New goalie pad set for spring.','Delivered and inspected - good.',1,1,'2026-04-20 22:18:05'),(7,7,4,8,'Received','2026-02-20','2026-02-28',440.00,'Gloves for new roster additions.','All delivered, sizes confirmed.',1,1,'2026-04-20 22:18:05'),(8,9,16,4,'Received','2026-01-10','2026-01-17',144.00,'Pucks for spring season opener.','Received on time.',1,1,'2026-04-20 22:18:05');
/*!40000 ALTER TABLE `equipment_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `financial_categories`
--

DROP TABLE IF EXISTS `financial_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `financial_categories` (
  `category_id` int NOT NULL AUTO_INCREMENT,
  `category_name` varchar(100) NOT NULL,
  `category_type` enum('Revenue','Expense') NOT NULL,
  PRIMARY KEY (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `financial_categories`
--

LOCK TABLES `financial_categories` WRITE;
/*!40000 ALTER TABLE `financial_categories` DISABLE KEYS */;
INSERT INTO `financial_categories` VALUES (1,'Ticket Sales','Revenue'),(2,'Donation','Revenue'),(3,'Sponsorship','Revenue'),(4,'Merchandise Sales','Revenue'),(5,'Ref Fees','Expense'),(6,'Ice Rental','Expense'),(7,'Travel','Expense'),(8,'Equipment','Expense'),(9,'Facility','Expense'),(10,'Food and Hospitality','Expense');
/*!40000 ALTER TABLE `financial_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `financial_entries`
--

DROP TABLE IF EXISTS `financial_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `financial_entries` (
  `entry_id` int NOT NULL AUTO_INCREMENT,
  `game_id` int DEFAULT NULL,
  `practice_id` int DEFAULT NULL,
  `category_id` int NOT NULL,
  `entry_type` enum('Revenue','Expense') NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `entry_date` date NOT NULL,
  PRIMARY KEY (`entry_id`),
  KEY `category_id` (`category_id`),
  KEY `idx_financial_entries_game` (`game_id`),
  KEY `idx_financial_entries_practice` (`practice_id`),
  CONSTRAINT `financial_entries_ibfk_1` FOREIGN KEY (`game_id`) REFERENCES `games` (`game_id`) ON DELETE SET NULL,
  CONSTRAINT `financial_entries_ibfk_2` FOREIGN KEY (`practice_id`) REFERENCES `practices` (`practice_id`) ON DELETE SET NULL,
  CONSTRAINT `financial_entries_ibfk_3` FOREIGN KEY (`category_id`) REFERENCES `financial_categories` (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=76 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `financial_entries`
--

LOCK TABLES `financial_entries` WRITE;
/*!40000 ALTER TABLE `financial_entries` DISABLE KEYS */;
INSERT INTO `financial_entries` VALUES (1,1,NULL,1,'Revenue',1500.00,'100 tickets sold at $15','2026-01-10'),(2,1,NULL,4,'Revenue',240.00,'Merchandise sales','2026-01-10'),(3,1,NULL,5,'Expense',300.00,'Referee fees','2026-01-10'),(4,1,NULL,6,'Expense',400.00,'Ice rental','2026-01-10'),(5,2,NULL,7,'Expense',520.00,'Bus transportation to AU','2026-01-17'),(6,2,NULL,5,'Expense',270.00,'Referee fees','2026-01-17'),(7,2,NULL,10,'Expense',100.00,'Team meal on road','2026-01-17'),(8,3,NULL,1,'Revenue',1650.00,'110 tickets sold at $15','2026-01-24'),(9,3,NULL,3,'Revenue',500.00,'Corporate sponsorship game night','2026-01-24'),(10,3,NULL,5,'Expense',300.00,'Referee fees','2026-01-24'),(11,3,NULL,6,'Expense',410.00,'Ice rental','2026-01-24'),(12,4,NULL,7,'Expense',850.00,'Charter bus to Penn State','2026-02-07'),(13,4,NULL,5,'Expense',290.00,'Referee fees','2026-02-07'),(14,4,NULL,10,'Expense',150.00,'Two team meals on road trip','2026-02-07'),(15,4,NULL,9,'Expense',55.00,'Facility access fee','2026-02-07'),(16,5,NULL,1,'Revenue',1950.00,'130 tickets sold at $15','2026-02-14'),(17,5,NULL,4,'Revenue',310.00,'Merchandise and concession share','2026-02-14'),(18,5,NULL,2,'Revenue',400.00,'Booster club donation at game','2026-02-14'),(19,5,NULL,5,'Expense',300.00,'Referee fees','2026-02-14'),(20,5,NULL,6,'Expense',415.00,'Ice rental','2026-02-14'),(21,6,NULL,7,'Expense',460.00,'Van rental and gas','2026-02-21'),(22,6,NULL,5,'Expense',270.00,'Referee fees','2026-02-21'),(23,7,NULL,1,'Revenue',1800.00,'120 tickets sold at $15','2026-03-07'),(24,7,NULL,4,'Revenue',290.00,'Merchandise sales','2026-03-07'),(25,7,NULL,5,'Expense',300.00,'Referee fees','2026-03-07'),(26,7,NULL,6,'Expense',400.00,'Ice rental','2026-03-07'),(27,8,NULL,1,'Revenue',1725.00,'115 tickets sold at $15','2026-03-14'),(28,8,NULL,3,'Revenue',750.00,'Mid-season sponsor payment','2026-03-14'),(29,8,NULL,5,'Expense',300.00,'Referee fees','2026-03-14'),(30,8,NULL,6,'Expense',400.00,'Ice rental','2026-03-14'),(31,8,NULL,10,'Expense',75.00,'Halftime refreshments','2026-03-14'),(32,9,NULL,1,'Revenue',1800.00,'120 tickets sold at $15','2026-03-18'),(33,9,NULL,4,'Revenue',320.00,'Game-day merchandise sales','2026-03-18'),(34,9,NULL,5,'Expense',300.00,'Referee fees','2026-03-18'),(35,9,NULL,6,'Expense',400.00,'Ice rental','2026-03-18'),(36,9,NULL,10,'Expense',150.00,'Snacks and drinks for event staff','2026-03-18'),(37,10,NULL,7,'Expense',500.00,'Bus transportation','2026-03-22'),(38,10,NULL,5,'Expense',280.00,'Referee fees','2026-03-22'),(39,10,NULL,10,'Expense',120.00,'Team food before game','2026-03-22'),(40,11,NULL,1,'Revenue',2100.00,'140 tickets sold at $15','2026-03-28'),(41,11,NULL,2,'Revenue',500.00,'Alumni donation received during event','2026-03-28'),(42,11,NULL,4,'Revenue',280.00,'Merchandise sales','2026-03-28'),(43,11,NULL,5,'Expense',300.00,'Referee fees','2026-03-28'),(44,11,NULL,6,'Expense',420.00,'Ice rental','2026-03-28'),(45,11,NULL,9,'Expense',100.00,'Arena support costs','2026-03-28'),(46,NULL,1,6,'Expense',290.00,'Practice ice rental - Jan 8','2026-01-08'),(47,NULL,1,10,'Expense',45.00,'Water and snacks','2026-01-08'),(48,NULL,2,6,'Expense',265.00,'Practice ice rental - Jan 13','2026-01-13'),(49,NULL,2,10,'Expense',40.00,'Post-practice snacks','2026-01-13'),(50,NULL,3,6,'Expense',280.00,'Practice ice rental - Jan 20','2026-01-20'),(51,NULL,3,8,'Expense',60.00,'New pucks and tape','2026-01-20'),(52,NULL,4,6,'Expense',285.00,'Practice ice rental - Jan 27','2026-01-27'),(53,NULL,4,10,'Expense',50.00,'Snacks and drinks','2026-01-27'),(54,NULL,5,6,'Expense',270.00,'Practice ice rental - Feb 3','2026-02-03'),(55,NULL,5,10,'Expense',55.00,'Post-scrimmage food','2026-02-03'),(56,NULL,6,6,'Expense',260.00,'Practice ice rental - Feb 10','2026-02-10'),(57,NULL,7,6,'Expense',275.00,'Practice ice rental - Feb 17','2026-02-17'),(58,NULL,7,8,'Expense',45.00,'Stick tape and misc supplies','2026-02-17'),(59,NULL,8,6,'Expense',255.00,'Practice ice rental - Feb 24','2026-02-24'),(60,NULL,9,6,'Expense',285.00,'Practice ice rental - Mar 3','2026-03-03'),(61,NULL,9,10,'Expense',50.00,'Energy drinks for late practice','2026-03-03'),(62,NULL,10,6,'Expense',275.00,'Practice ice rental - Mar 10','2026-03-10'),(63,NULL,11,6,'Expense',240.00,'Practice ice rental - Mar 12','2026-03-12'),(64,NULL,11,10,'Expense',55.00,'Water and snacks - Mar 12','2026-03-12'),(65,NULL,12,6,'Expense',250.00,'Practice ice rental - Mar 14','2026-03-14'),(66,NULL,12,10,'Expense',30.00,'Post-practice snacks - Mar 14','2026-03-14'),(67,NULL,13,6,'Expense',260.00,'Practice ice rental - Mar 16','2026-03-16'),(68,NULL,13,8,'Expense',55.00,'Pucks and tape for practice','2026-03-16'),(69,NULL,NULL,2,'Revenue',1500.00,'General alumni donation - spring drive','2026-04-01'),(70,NULL,NULL,3,'Revenue',2000.00,'Annual jersey sponsorship - Terrapin Sports','2026-01-05'),(71,NULL,NULL,3,'Revenue',1200.00,'Booster club contribution Q1','2026-02-01'),(72,NULL,NULL,8,'Expense',725.00,'General equipment order - sticks and pads','2026-04-03'),(73,NULL,NULL,8,'Expense',450.00,'Helmet replacement - 3 units','2026-02-15'),(74,NULL,NULL,9,'Expense',350.00,'Locker room maintenance fee','2026-03-01'),(75,NULL,NULL,7,'Expense',200.00,'Gas reimbursements for carpool games','2026-02-28');
/*!40000 ALTER TABLE `financial_entries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `financial_projections`
--

DROP TABLE IF EXISTS `financial_projections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `financial_projections` (
  `projection_id` int NOT NULL AUTO_INCREMENT,
  `game_id` int DEFAULT NULL,
  `practice_id` int DEFAULT NULL,
  `category_id` int NOT NULL,
  `projection_type` enum('Revenue','Expense') NOT NULL,
  `projected_amount` decimal(10,2) NOT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `projection_date` date NOT NULL,
  PRIMARY KEY (`projection_id`),
  KEY `category_id` (`category_id`),
  KEY `idx_financial_projections_game` (`game_id`),
  KEY `idx_financial_projections_practice` (`practice_id`),
  CONSTRAINT `financial_projections_ibfk_1` FOREIGN KEY (`game_id`) REFERENCES `games` (`game_id`) ON DELETE SET NULL,
  CONSTRAINT `financial_projections_ibfk_2` FOREIGN KEY (`practice_id`) REFERENCES `practices` (`practice_id`) ON DELETE SET NULL,
  CONSTRAINT `financial_projections_ibfk_3` FOREIGN KEY (`category_id`) REFERENCES `financial_categories` (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=56 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `financial_projections`
--

LOCK TABLES `financial_projections` WRITE;
/*!40000 ALTER TABLE `financial_projections` DISABLE KEYS */;
INSERT INTO `financial_projections` VALUES (1,1,NULL,1,'Revenue',1400.00,'Projected ticket sales','2026-01-10'),(2,1,NULL,5,'Expense',300.00,'Projected ref fees','2026-01-10'),(3,1,NULL,6,'Expense',400.00,'Projected ice rental','2026-01-10'),(4,3,NULL,1,'Revenue',1500.00,'Projected ticket sales','2026-01-24'),(5,3,NULL,3,'Revenue',400.00,'Projected sponsorship','2026-01-24'),(6,3,NULL,5,'Expense',300.00,'Projected ref fees','2026-01-24'),(7,3,NULL,6,'Expense',420.00,'Projected ice rental','2026-01-24'),(8,4,NULL,7,'Expense',800.00,'Projected charter bus','2026-02-07'),(9,4,NULL,5,'Expense',290.00,'Projected ref fees','2026-02-07'),(10,4,NULL,10,'Expense',120.00,'Projected meals','2026-02-07'),(11,5,NULL,1,'Revenue',1800.00,'Projected ticket sales','2026-02-14'),(12,5,NULL,4,'Revenue',280.00,'Projected merch sales','2026-02-14'),(13,5,NULL,5,'Expense',300.00,'Projected ref fees','2026-02-14'),(14,5,NULL,6,'Expense',420.00,'Projected ice rental','2026-02-14'),(15,9,NULL,1,'Revenue',1700.00,'Projected ticket sales','2026-03-18'),(16,9,NULL,4,'Revenue',300.00,'Projected merchandise sales','2026-03-18'),(17,9,NULL,5,'Expense',300.00,'Projected ref fees','2026-03-18'),(18,9,NULL,6,'Expense',425.00,'Projected ice rental','2026-03-18'),(19,10,NULL,7,'Expense',520.00,'Projected travel cost','2026-03-22'),(20,10,NULL,5,'Expense',275.00,'Projected ref fees','2026-03-22'),(21,10,NULL,10,'Expense',125.00,'Projected food cost','2026-03-22'),(22,11,NULL,1,'Revenue',2000.00,'Projected ticket sales','2026-03-28'),(23,11,NULL,2,'Revenue',400.00,'Projected donations','2026-03-28'),(24,11,NULL,4,'Revenue',250.00,'Projected merchandise sales','2026-03-28'),(25,11,NULL,5,'Expense',300.00,'Projected ref fees','2026-03-28'),(26,11,NULL,6,'Expense',450.00,'Projected ice rental','2026-03-28'),(27,12,NULL,7,'Expense',820.00,'Projected bus to Hopkins','2026-04-07'),(28,12,NULL,5,'Expense',290.00,'Projected ref fees','2026-04-07'),(29,12,NULL,10,'Expense',130.00,'Projected team meal','2026-04-07'),(30,13,NULL,1,'Revenue',1800.00,'Projected ticket sales','2026-04-12'),(31,13,NULL,4,'Revenue',300.00,'Projected merch','2026-04-12'),(32,13,NULL,5,'Expense',300.00,'Projected ref fees','2026-04-12'),(33,13,NULL,6,'Expense',420.00,'Projected ice rental','2026-04-12'),(34,14,NULL,7,'Expense',950.00,'Projected overnight travel','2026-04-19'),(35,14,NULL,5,'Expense',290.00,'Projected ref fees','2026-04-19'),(36,14,NULL,10,'Expense',200.00,'Projected meals - overnight trip','2026-04-19'),(37,15,NULL,1,'Revenue',2200.00,'Alumni game - higher turnout expected','2026-04-26'),(38,15,NULL,2,'Revenue',600.00,'Projected alumni donations at game','2026-04-26'),(39,15,NULL,5,'Expense',300.00,'Projected ref fees','2026-04-26'),(40,15,NULL,6,'Expense',420.00,'Projected ice rental','2026-04-26'),(41,15,NULL,10,'Expense',300.00,'Projected food and hospitality','2026-04-26'),(42,NULL,1,6,'Expense',300.00,'Projected ice rental - Jan 8','2026-01-08'),(43,NULL,1,10,'Expense',50.00,'Projected snacks','2026-01-08'),(44,NULL,5,6,'Expense',275.00,'Projected ice rental - Feb 3','2026-02-03'),(45,NULL,5,10,'Expense',50.00,'Projected snacks','2026-02-03'),(46,NULL,11,6,'Expense',250.00,'Projected ice rental - Mar 12','2026-03-12'),(47,NULL,11,10,'Expense',50.00,'Projected snacks - Mar 12','2026-03-12'),(48,NULL,12,6,'Expense',250.00,'Projected ice rental - Mar 14','2026-03-14'),(49,NULL,12,10,'Expense',25.00,'Projected snacks - Mar 14','2026-03-14'),(50,NULL,13,6,'Expense',260.00,'Projected ice rental - Mar 16','2026-03-16'),(51,NULL,13,8,'Expense',60.00,'Projected supplies - Mar 16','2026-03-16'),(52,NULL,14,6,'Expense',285.00,'Projected ice rental - Apr 2','2026-04-02'),(53,NULL,14,10,'Expense',45.00,'Projected snacks - Apr 2','2026-04-02'),(54,NULL,15,6,'Expense',295.00,'Projected ice rental - Apr 9','2026-04-09'),(55,NULL,16,6,'Expense',275.00,'Projected ice rental - Apr 14','2026-04-14');
/*!40000 ALTER TABLE `financial_projections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `games`
--

DROP TABLE IF EXISTS `games`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `games` (
  `game_id` int NOT NULL AUTO_INCREMENT,
  `opponent` varchar(100) NOT NULL,
  `game_date` date NOT NULL,
  `location` varchar(150) NOT NULL,
  `game_type` enum('Home','Away') NOT NULL,
  `status` enum('Scheduled','Confirmed','Completed','Cancelled') DEFAULT 'Scheduled',
  `projected_cost` decimal(10,2) DEFAULT NULL,
  `actual_cost` decimal(10,2) DEFAULT NULL,
  `final_score` varchar(50) DEFAULT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `in_results` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`game_id`),
  KEY `idx_games_date` (`game_date`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `games`
--

LOCK TABLES `games` WRITE;
/*!40000 ALTER TABLE `games` DISABLE KEYS */;
INSERT INTO `games` VALUES (1,'Georgetown Club Hockey','2026-01-10','UMD Ice Arena','Home','Completed',620.00,598.00,'UMD 5 - Georgetown 1','Strong start to the spring semester',1),(2,'American University','2026-01-17','AU Ice Center','Away','Completed',850.00,890.00,'UMD 2 - AU 3','Overtime loss, close game',1),(3,'Virginia Tech Club','2026-01-24','UMD Ice Arena','Home','Completed',600.00,575.00,'UMD 4 - VT 2','Good crowd for a January game',1),(4,'Penn State Club','2026-02-07','Penn State Ice Rink','Away','Completed',1100.00,1145.00,'UMD 1 - PSU 4','Long bus trip, tough loss',1),(5,'George Washington','2026-02-14','UMD Ice Arena','Home','Completed',650.00,630.00,'UMD 6 - GWU 0','Valentine\'s Day shutout win',1),(6,'Catholic University','2026-02-21','Catholic Ice Rink','Away','Completed',780.00,760.00,'UMD 3 - CU 3','Tie game, split point',1),(7,'Georgetown Club Hockey','2026-03-07','UMD Ice Arena','Home','Completed',640.00,615.00,'UMD 4 - Georgetown 1','Rematch win at home',1),(8,'Navy Club Hockey','2026-03-14','UMD Ice Arena','Home','Completed',670.00,650.00,'UMD 5 - Navy 2','Home win before road trip',1),(9,'Georgetown Club Hockey','2026-03-18','UMD Ice Arena','Home','Completed',650.00,620.00,'UMD 4 - Georgetown 2','Strong home turnout and alumni support',1),(10,'Navy Club Hockey','2026-03-22','Navy Ice Rink','Away','Completed',900.00,950.00,'UMD 3 - Navy 5','Bus and travel meal costs ran high',1),(11,'Towson','2026-03-28','UMD Ice Arena','Home','Completed',700.00,675.00,'UMD 6 - Towson 1','Senior recognition night',1),(12,'Johns Hopkins','2026-04-07','Johns Hopkins Rink','Away','Confirmed',850.00,NULL,NULL,'Need final bus confirmation',0),(13,'George Mason','2026-04-12','UMD Ice Arena','Home','Scheduled',600.00,NULL,NULL,'Potential fundraising table in lobby',0),(14,'Delaware Club Hockey','2026-04-19','Delaware Ice Center','Away','Scheduled',980.00,NULL,NULL,'Overnight travel may be needed',0),(15,'Maryland Alumni','2026-04-26','UMD Ice Arena','Home','Scheduled',500.00,NULL,NULL,'Food and drinks planned after game',0),(16,'Virginia Tech Club','2026-05-02','Cassell Coliseum Ice','Away','Scheduled',1050.00,NULL,NULL,'End of season road game',0),(17,'American University','2026-05-09','UMD Ice Arena','Home','Scheduled',620.00,NULL,NULL,'Final home game of the season',0);
/*!40000 ALTER TABLE `games` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory_items`
--

DROP TABLE IF EXISTS `inventory_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory_items` (
  `item_id` int NOT NULL AUTO_INCREMENT,
  `item_name` varchar(150) NOT NULL,
  `category` varchar(100) NOT NULL,
  `item_type` enum('New','Used','Replacement') NOT NULL DEFAULT 'New',
  `description` varchar(255) DEFAULT NULL,
  `source` varchar(150) DEFAULT NULL,
  `quantity` int NOT NULL DEFAULT '0',
  `reorder_level` int NOT NULL DEFAULT '3',
  `unit_cost` decimal(10,2) DEFAULT NULL,
  `status` enum('In Stock','Low Stock','Out of Stock') NOT NULL DEFAULT 'In Stock',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`item_id`),
  KEY `idx_inventory_category` (`category`),
  KEY `idx_inventory_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory_items`
--

LOCK TABLES `inventory_items` WRITE;
/*!40000 ALTER TABLE `inventory_items` DISABLE KEYS */;
INSERT INTO `inventory_items` VALUES (1,'Red Bauer Helmet','Helmet','New','Primary varsity helmet','Team Supplier',5,3,89.99,'In Stock','2026-04-20 22:18:05'),(2,'Home Jerseys','Jersey','Replacement','White game jerseys','Campus Sports Store',12,5,65.00,'In Stock','2026-04-20 22:18:05'),(3,'Shoulder Pads','Pads','New','Senior and JV shoulder pads','Online Order',2,4,74.50,'Low Stock','2026-04-20 22:18:05'),(4,'Practice Sticks','Stick','Used','Shared practice sticks','Team Supplier',10,4,45.00,'In Stock','2026-04-20 22:18:05'),(5,'Away Jerseys','Jersey','Replacement','Dark road jerseys','Campus Sports Store',8,5,65.00,'In Stock','2026-04-20 22:18:05'),(6,'Goalie Pads - Large','Pads','New','Full leg pad set for goalies','Online Order',1,2,320.00,'Low Stock','2026-04-20 22:18:05'),(7,'Hockey Gloves','Gloves','New','Player gloves - medium and large mix','Team Supplier',6,4,55.00,'In Stock','2026-04-20 22:18:05'),(8,'Skate Blades','Skates','Replacement','Replacement blades - standard size','Online Order',3,4,28.00,'Low Stock','2026-04-20 22:18:05'),(9,'Puck Set (24-pack)','Equipment','New','Official game pucks','Team Supplier',4,2,36.00,'In Stock','2026-04-20 22:18:05'),(10,'Water Bottles (20-pack)','Equipment','New','Team water bottles with logo','Campus Sports Store',15,5,18.00,'In Stock','2026-04-20 22:18:05'),(11,'First Aid Kit','Medical','Replacement','Bench-side first aid kit','Online Order',2,2,45.00,'In Stock','2026-04-20 22:18:05'),(12,'Stick Tape (36-roll)','Equipment','New','Black and white stick tape rolls','Team Supplier',0,3,22.00,'Out of Stock','2026-04-20 22:18:05');
/*!40000 ALTER TABLE `inventory_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `newsletters`
--

DROP TABLE IF EXISTS `newsletters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `newsletters` (
  `newsletter_id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(200) NOT NULL,
  `content` text NOT NULL,
  `created_by` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`newsletter_id`),
  KEY `created_by` (`created_by`),
  CONSTRAINT `newsletters_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `newsletters`
--

LOCK TABLES `newsletters` WRITE;
/*!40000 ALTER TABLE `newsletters` DISABLE KEYS */;
INSERT INTO `newsletters` VALUES (1,'Spring Season Kickoff - January Update','Dear Terps Hockey supporters, we are thrilled to kick off the spring semester with a strong roster and exciting schedule. Our first home game is January 10th against Georgetown. Come out and support the team! We have expanded seating and new merchandise available at the arena. Season tickets are still available - contact the athletic office for details.',1,'2026-04-20 22:18:04'),(2,'February Game Recap and Upcoming Schedule','What a month! We defeated Virginia Tech at home and had a tough road trip to Penn State. The team is playing hard and our defense has been outstanding. Coming up in February: home game against George Washington on Valentine\'s Day - bring your family and friends for a great night of hockey. Merchandise booth will be open two hours before puck drop.',2,'2026-04-20 22:18:04'),(3,'Alumni Spotlight - Donate and Make a Difference','This month we are highlighting our incredible alumni who have given back to the program. Thanks to your generosity we have been able to purchase new helmets, upgrade ice time, and support travel costs. If you have not yet donated this season, please consider a contribution of any size. Every dollar goes directly to supporting our student athletes.',1,'2026-04-20 22:18:04'),(4,'Mid-Season Update - February 2026','We are at the midpoint of our spring season with a 4-2-1 record. Highlights include our Valentine\'s Day shutout victory against GWU and a competitive road tie against Catholic University. The team has been putting in extra practice hours and it shows. Next home game is March 7th - see you at the rink!',2,'2026-04-20 22:18:04'),(5,'March Stretch Run - Final Push Before Playoffs','The team is in full swing with four games remaining before the postseason. Senior Night is March 28th vs Towson - join us as we honor our graduating players. There will be a post-game reception with alumni and families in the lobby. Reserve your tickets early as this game typically sells out.',1,'2026-04-20 22:18:04'),(6,'Senior Night Recap and Spring Schedule Preview','What an incredible night honoring our seniors! The team delivered a dominant 6-1 victory over Towson in front of a packed arena. Thank you to everyone who came out to show your support. Looking ahead, we have four exciting games in April and May. The alumni game on April 26th is shaping up to be a highlight of the year.',2,'2026-04-20 22:18:04'),(7,'April Newsletter - Alumni Game Preview','The annual alumni game is just around the corner on April 26th at UMD Ice Arena. We are expecting over 20 alumni to return and compete against the current roster. There will be a tailgate starting at 4pm, game at 6pm, and a reception after. All proceeds from ticket sales and donations go directly to the team equipment fund.',1,'2026-04-20 22:18:04');
/*!40000 ALTER TABLE `newsletters` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `players`
--

DROP TABLE IF EXISTS `players`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `players` (
  `player_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `jersey_number` int DEFAULT NULL,
  `position` varchar(50) DEFAULT NULL,
  `year` varchar(50) DEFAULT NULL,
  `injured` tinyint(1) DEFAULT '0',
  `phone` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`player_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `players_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `players`
--

LOCK TABLES `players` WRITE;
/*!40000 ALTER TABLE `players` DISABLE KEYS */;
INSERT INTO `players` VALUES (1,3,27,'Forward','Sophomore',0,'555-123-4567'),(2,5,10,'Defense','Senior',0,'555-222-1111'),(3,6,14,'Forward','Junior',1,'555-222-3333'),(4,7,31,'Goalie','Freshman',0,'555-222-4444'),(5,8,7,'Forward','Junior',0,'555-333-1001'),(6,9,22,'Defense','Sophomore',0,'555-333-1002'),(7,10,18,'Forward','Senior',1,'555-333-1003'),(8,11,3,'Defense','Freshman',0,'555-333-1004'),(9,12,11,'Forward','Junior',0,'555-333-1005'),(10,13,44,'Defense','Senior',0,'555-333-1006'),(11,14,19,'Goalie','Sophomore',0,'555-333-1007'),(12,15,8,'Forward','Junior',0,'555-333-1008');
/*!40000 ALTER TABLE `players` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `practices`
--

DROP TABLE IF EXISTS `practices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `practices` (
  `practice_id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(150) NOT NULL,
  `practice_date` date NOT NULL,
  `practice_time` time NOT NULL,
  `location` varchar(150) NOT NULL,
  `contact_email` varchar(100) DEFAULT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `status` enum('Scheduled','Confirmed','Completed','Cancelled') DEFAULT 'Scheduled',
  `projected_cost` decimal(10,2) DEFAULT NULL,
  `actual_cost` decimal(10,2) DEFAULT NULL,
  `in_results` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`practice_id`),
  KEY `idx_practices_date_time` (`practice_date`,`practice_time`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `practices`
--

LOCK TABLES `practices` WRITE;
/*!40000 ALTER TABLE `practices` DISABLE KEYS */;
INSERT INTO `practices` VALUES (1,'Terps Ice Hockey Practice','2026-01-08','19:00:00','Campus Ice Rink','ice@rink.com','Season opener skate - conditioning focus','Completed',300.00,295.00,1),(2,'Terps Ice Hockey Practice','2026-01-13','19:00:00','Community Ice Arena','ice@rink.com','Power play and defensive zone work','Completed',275.00,280.00,1),(3,'Terps Ice Hockey Practice','2026-01-20','18:30:00','Campus Ice Rink','ice@rink.com','Line combinations and neutral zone','Completed',325.00,315.00,1),(4,'Terps Ice Hockey Practice','2026-01-27','19:00:00','Campus Ice Rink','ice@rink.com','Penalty kill and 5-on-3 defense','Completed',300.00,310.00,1),(5,'Terps Ice Hockey Practice','2026-02-03','19:00:00','Community Ice Arena','ice@rink.com','Full scrimmage with video review','Completed',310.00,305.00,1),(6,'Terps Ice Hockey Practice','2026-02-10','18:30:00','Campus Ice Rink','ice@rink.com','Pre-PSU game skate','Completed',290.00,285.00,1),(7,'Terps Ice Hockey Practice','2026-02-17','19:00:00','Campus Ice Rink','ice@rink.com','Breakout drills and transition play','Completed',300.00,298.00,1),(8,'Terps Ice Hockey Practice','2026-02-24','19:00:00','Community Ice Arena','ice@rink.com','Special teams focus','Completed',275.00,270.00,1),(9,'Terps Ice Hockey Practice','2026-03-03','18:30:00','Campus Ice Rink','ice@rink.com','Mid-season assessment skate','Completed',310.00,315.00,1),(10,'Terps Ice Hockey Practice','2026-03-10','19:00:00','Campus Ice Rink','ice@rink.com','Pre-stretch run conditioning','Completed',300.00,295.00,1),(11,'Terps Ice Hockey Practice','2026-03-12','19:00:00','Campus Ice Rink','ice@rink.com','Power play and defensive zone','Completed',300.00,295.00,1),(12,'Terps Ice Hockey Practice','2026-03-14','19:00:00','Community Ice Arena','ice@rink.com','Scrimmage and line combinations','Completed',275.00,280.00,1),(13,'Terps Ice Hockey Practice','2026-03-16','18:30:00','Campus Ice Rink','ice@rink.com','Game prep and penalty kill','Completed',325.00,315.00,1),(14,'Terps Ice Hockey Practice','2026-04-02','19:00:00','Campus Ice Rink','ice@rink.com','Spring training kickoff','Confirmed',300.00,NULL,0),(15,'Terps Ice Hockey Practice','2026-04-09','19:00:00','Community Ice Arena','ice@rink.com','Open ice and line rushes','Scheduled',310.00,NULL,0),(16,'Terps Ice Hockey Practice','2026-04-14','18:30:00','Campus Ice Rink','ice@rink.com','Pre-Delaware game skate','Scheduled',290.00,NULL,0),(17,'Terps Ice Hockey Practice','2026-04-21','19:00:00','Campus Ice Rink','ice@rink.com','Post-Delaware recovery and film','Scheduled',300.00,NULL,0),(18,'Terps Ice Hockey Practice','2026-04-28','19:00:00','Community Ice Arena','ice@rink.com','End of season conditioning','Scheduled',310.00,NULL,0),(19,'Terps Ice Hockey Practice','2026-05-05','18:30:00','Campus Ice Rink','ice@rink.com','Final prep before season close','Scheduled',300.00,NULL,0);
/*!40000 ALTER TABLE `practices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sent_messages`
--

DROP TABLE IF EXISTS `sent_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sent_messages` (
  `message_id` int NOT NULL AUTO_INCREMENT,
  `recipients` varchar(100) NOT NULL,
  `subject` varchar(200) DEFAULT NULL,
  `body` text,
  `sent_by` int NOT NULL,
  `sent_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`message_id`),
  KEY `sent_by` (`sent_by`),
  CONSTRAINT `sent_messages_ibfk_1` FOREIGN KEY (`sent_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sent_messages`
--

LOCK TABLES `sent_messages` WRITE;
/*!40000 ALTER TABLE `sent_messages` DISABLE KEYS */;
INSERT INTO `sent_messages` VALUES (1,'All Players','Spring Season Schedule Posted','Hey team, the full spring schedule is now live in the system. Check the schedule tab for all game and practice dates. First practice is January 8th. See you on the ice!',2,'2026-04-20 22:18:05'),(2,'All Players','Practice Reminder - January 13th','Reminder that practice is tomorrow Tuesday January 13th at 7pm at Community Ice Arena. Full equipment required. We will be working on power play and defensive zone coverage.',2,'2026-04-20 22:18:05'),(3,'All Players','Game Day - Georgetown January 10th','Game day reminder - tonight vs Georgetown at UMD Ice Arena. Doors open at 6pm, puck drop at 7:30pm. Please arrive by 6pm for warmups. Bring your student ID for team check-in.',1,'2026-04-20 22:18:05'),(4,'All Players','PSU Road Trip Details','For the Penn State away game on Feb 7th - bus departs UMD South Campus at 9am sharp. Bring snacks and be prepared for a 3 hour ride. Hotel info has been emailed separately.',2,'2026-04-20 22:18:05'),(5,'Offense Players','Offensive Zone Drill Review','Offense group - please watch the video I shared in the team GroupMe before our next practice. We will be running the new breakout drill and I want everyone familiar with their assignments.',2,'2026-04-20 22:18:05'),(6,'All Players','Senior Night - March 28th','Mark your calendars - Senior Night is March 28th vs Towson. This is a special evening honoring our graduating players. Please invite family and friends. There will be a post-game reception in the lobby.',1,'2026-04-20 22:18:05'),(7,'All Players','April Schedule and Alumni Game Info','April schedule is finalized. Please note the alumni game on April 26th - all current players are expected to participate. This is a huge event for program fundraising and alumni relations.',1,'2026-04-20 22:18:05'),(8,'Defense Players','Defensive Zone Coverage - Film Session','Defense group - mandatory film session this Thursday at 5pm in the athletic conference room before practice. We will review coverage breakdowns from the Navy away game.',2,'2026-04-20 22:18:05');
/*!40000 ALTER TABLE `sent_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subscribers`
--

DROP TABLE IF EXISTS `subscribers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subscribers` (
  `subscriber_id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(100) NOT NULL,
  `date_added` date NOT NULL,
  `status` enum('Active','Pending','Inactive') NOT NULL DEFAULT 'Active',
  PRIMARY KEY (`subscriber_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscribers`
--

LOCK TABLES `subscribers` WRITE;
/*!40000 ALTER TABLE `subscribers` DISABLE KEYS */;
INSERT INTO `subscribers` VALUES (1,'fan1@email.com','2026-01-15','Active'),(2,'alumni1@email.com','2026-02-02','Active'),(3,'supporter@email.com','2026-02-18','Active'),(4,'familymember@email.com','2026-03-01','Pending'),(5,'hockeymom22@gmail.com','2026-01-08','Active'),(6,'terps4ever@yahoo.com','2026-01-10','Active'),(7,'umd_proud@hotmail.com','2026-01-12','Active'),(8,'icehockey_fan@gmail.com','2026-01-20','Active'),(9,'goterps2026@gmail.com','2026-02-05','Active'),(10,'supportermd@gmail.com','2026-02-10','Active'),(11,'rinkside_fan@gmail.com','2026-02-14','Active'),(12,'terrapinfan@outlook.com','2026-02-20','Pending'),(13,'alumni_2019@gmail.com','2026-03-01','Active'),(14,'maryland_hockey@gmail.com','2026-03-05','Active'),(15,'puckdrop@gmail.com','2026-03-10','Active'),(16,'icearena_regular@gmail.com','2026-03-15','Active'),(17,'family_section@gmail.com','2026-03-18','Active'),(18,'boosterclub@umd.edu','2026-03-20','Active'),(19,'terps_superfan@gmail.com','2026-03-25','Active'),(20,'hockey_parent@gmail.com','2026-04-01','Active');
/*!40000 ALTER TABLE `subscribers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Admin User','admin@umd.edu','scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d','Admin'),(2,'Coach User','coach@umd.edu','scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d','Coach'),(3,'Player User','player@umd.edu','scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d','Player'),(4,'Supplier User','supplier@umd.edu','scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d','Supplier'),(5,'Marco Rossi','marco.rossi@umd.edu','scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d','Player'),(6,'Jake Thompson','jake.thompson@umd.edu','scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d','Player'),(7,'Liam Connor','liam.connor@umd.edu','scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d','Player'),(8,'Tyler Brooks','tyler.brooks@umd.edu','scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d','Player'),(9,'Evan Walsh','evan.walsh@umd.edu','scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d','Player'),(10,'Chris Navarro','chris.navarro@umd.edu','scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d','Player'),(11,'Derek Huang','derek.huang@umd.edu','scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d','Player'),(12,'Mason Price','mason.price@umd.edu','scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d','Player'),(13,'Owen Fitzgerald','owen.fitz@umd.edu','scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d','Player'),(14,'Nate Summers','nate.summers@umd.edu','scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d','Player'),(15,'Brady Okafor','brady.okafor@umd.edu','scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d','Player'),(16,'Sports Supply Co','supplier2@sportssupply.com','scrypt:32768:8:1$JJ3eNoPuCRp6X5Jd$f1d550168a9c313512a23d86fc3a4b107f03211228d1222d8e87b259c75b75988ad8d63d6a7029b8b0d038520f4dfce7519e2f0cb39a827e82784b13296cf70d','Supplier');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-20 20:59:34
