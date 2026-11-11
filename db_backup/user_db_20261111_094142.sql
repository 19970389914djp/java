-- MySQL dump 10.13  Distrib 8.0.39, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: user_db
-- ------------------------------------------------------
-- Server version	8.0.39

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `user_db`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `user_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `user_db`;

--
-- Table structure for table `honor`
--

DROP TABLE IF EXISTS `honor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `honor` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `label` varchar(50) NOT NULL COMMENT '荣誉名称（如：总冠军）',
  `value` varchar(50) NOT NULL COMMENT '荣誉数值（如：4、40000+）',
  `sort_order` int NOT NULL DEFAULT '0' COMMENT '展示顺序，越小越靠前',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='生涯荣誉';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `honor`
--

LOCK TABLES `honor` WRITE;
/*!40000 ALTER TABLE `honor` DISABLE KEYS */;
INSERT INTO `honor` VALUES (1,'总冠军','4',1),(2,'总决赛 MVP','4',2),(3,'常规赛 MVP','4',3),(4,'全明星','20次',4),(5,'历史总得分王','40000+',5),(6,'历史助攻王','11000+',6);
/*!40000 ALTER TABLE `honor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hot_keyword`
--

DROP TABLE IF EXISTS `hot_keyword`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hot_keyword` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `keyword` varchar(50) NOT NULL COMMENT '搜索词',
  `sort_order` int NOT NULL DEFAULT '0' COMMENT '展示顺序，越小越靠前',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='热门搜索词';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hot_keyword`
--

LOCK TABLES `hot_keyword` WRITE;
/*!40000 ALTER TABLE `hot_keyword` DISABLE KEYS */;
INSERT INTO `hot_keyword` VALUES (1,'总冠军',1),(2,'2016',2),(3,'湖人',3),(4,'40000分',4),(5,'天选之子',5),(6,'摊手',6),(7,'勇士',7);
/*!40000 ALTER TABLE `hot_keyword` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `moment`
--

DROP TABLE IF EXISTS `moment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `moment` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `year` varchar(10) NOT NULL COMMENT '年份（展示用，如 2016、23）',
  `title` varchar(100) NOT NULL COMMENT '标题',
  `description` varchar(500) NOT NULL COMMENT '描述',
  `tags` varchar(200) NOT NULL DEFAULT '' COMMENT '标签，逗号分隔（如：骑士,总冠军,翻盘）',
  `image` varchar(300) NOT NULL DEFAULT '' COMMENT '配图路径（前端优先使用）',
  `sort_order` int NOT NULL DEFAULT '0' COMMENT '展示顺序，越小越靠前',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_year` (`year`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='高光时刻';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `moment`
--

LOCK TABLES `moment` WRITE;
/*!40000 ALTER TABLE `moment` DISABLE KEYS */;
INSERT INTO `moment` VALUES (1,'2003','天选之子降临','阿克伦之子以状元身份加盟克利夫兰骑士，The Chosen One 的故事从此开始。','骑士,选秀,状元','/images/moment-2003.jpg',1,'2026-11-11 08:51:15'),(2,'2012','首冠加冕','迈阿密之夜，击败雷霆捧起生涯第一座总冠军奖杯，王者之路正式启程。','热火,总冠军','/images/moment-2012.jpg',2,'2026-11-11 08:51:15'),(3,'2013','卫冕之战','总决赛对阵马刺，37 分神奇一波流续命，最终卫冕成功并再夺 FMVP。','热火,总冠军,卫冕','/images/moment-2012.jpg',3,'2026-11-11 08:51:15'),(4,'2016','1-3 史诗翻盘','总决赛 1-3 落后 73 胜勇士，连扳三场为克利夫兰带来 52 年首座冠军。','骑士,总冠军,翻盘','/images/moment-2016-block.jpg',4,'2026-11-11 08:51:15'),(5,'2016','The Block','抢七最后时刻追身大帽伊戈达拉，史诗级防守载入史册。','骑士,名场面,防守','/images/moment-2016-block.jpg',5,'2026-11-11 08:51:15'),(6,'2020','紫金复辟','率领湖人夺得队史第 17 冠，为科比而战，紫金王朝再度闪耀。','湖人,总冠军,曼巴','/images/moment-2020.jpg',6,'2026-11-11 08:51:15'),(7,'2024','40000 分里程碑','成为 NBA 历史首位生涯总得分突破 40000 分的球员，前无古人。','湖人,里程碑,得分王','/images/moment-40000.jpg',7,'2026-11-11 08:51:15'),(8,'23','粉笔仪式','赛前撒镁粉的标志性仪式，从克利夫兰到洛杉矶，仪式感拉满。','仪式,23号','/images/moment-ritual.jpg',8,'2026-11-11 08:51:15'),(9,'2007','幼詹初遇马刺','22 岁单核带队首次闯入总决赛，却被邓肯领衔的马刺 4-0 横扫。邓肯赛后留下名言：\"未来是你的。\"','骑士,总决赛,马刺','/images/moment-2007-spurs.jpg',9,'2026-11-11 08:51:15'),(10,'2011','巅峰翻车小牛','巅峰三巨头对阵诺维茨基单核小牛，大热倒灶 2-4 痛失冠军，场均 17.8 分成生涯总决赛最低谷。','热火,总决赛,小牛','/images/moment-2011-mavs.jpg',10,'2026-11-11 08:51:15'),(11,'2014','再遇马刺团战','总决赛再碰马刺，被行云流水的团队篮球 1-4 教做人，热火两冠王朝就此落幕。','热火,总决赛,马刺','/images/moment-2014-spurs.jpg',11,'2026-11-11 08:51:15'),(12,'2015','孤军奋战勇士','总决赛乐福、欧文相继报销，独木难支苦战六场 2-4 不敌勇士，虽败犹荣。','骑士,总决赛,勇士','/images/moment-2015-finals.jpg',12,'2026-11-11 08:51:15'),(13,'2017','遭遇宇宙勇','勇士迎来杜兰特组成\"宇宙勇\"，1-4 无力回天，唯一亮点是总决赛场均三双。','骑士,总决赛,勇士','/images/moment-2017-finals.jpg',13,'2026-11-11 08:51:15'),(14,'2018','最后的骑士','总决赛首战狂砍 51 分却遭 JR \"神之大脑\"错失良机，随后被勇士横扫，骑士 2.0 时代落幕。','骑士,总决赛,勇士,横扫','/images/moment-2018-finals.jpg',14,'2026-11-11 08:51:15'),(15,'23','经典摊手','突破被犯规裁判没吹？标志性摊手质问裁判，委屈值拉满，本场镜头必定给特写。','摊手,名场面,搞笑','/images/meme-shrug.jpg',15,'2026-11-11 08:51:15'),(16,'23','惊天一跪','对关键判罚不满？直接跪地抗议！这一跪跪出了全网热度，也跪进了表情包素材库。','惊天一跪,名场面,搞笑','/images/meme-kneel.jpg',16,'2026-11-11 08:51:15'),(17,'23','下快攻一条龙','攻防转换瞬间起速，坦克式突破碾压全场，一条龙战斧劈扣收尾，观赏性直接拉满。','快攻,扣篮,名场面','/images/meme-fastbreak.jpg',17,'2026-11-11 08:51:15'),(18,'23','边线看戏式防守','攻防转换突然隐身，站在边线看队友 4 打 5，\"保留体力\"的赛场哲学每次都引发热议。','不防守,看戏,搞笑','/images/meme-watch.jpg',18,'2026-11-11 08:51:15'),(19,'23','跳投伸腿名场面','三分出手后双腿前伸，防守人纷纷中招，\"落地空间\"之争成了联盟最难解的题。','垫脚,争议,搞笑','/images/meme-stepover.jpg',19,'2026-11-11 08:51:15'),(20,'2018','戳眼风波','总决赛被格林戳到眼角充血，单眼模糊仍砍 51 分，赛后眼伤照片吓坏球迷。','勇士,名场面,2018','/images/meme-eye.jpg',20,'2026-11-11 08:51:15'),(21,'23','隐形小推手','卡位时裁判视野之外的暗中小推，慢镜头回放反复调侃，\"球星福利\"名不虚传。','推人,争议,搞笑','/images/meme-push.jpg',21,'2026-11-11 08:51:15'),(22,'23','打铁撸头杀','投篮打铁后的标志性撸头动作，压力值可视化，懊恼直接写在全国观众眼前。','撸头,搞笑,名场面','/images/meme-headrub.jpg',22,'2026-11-11 08:51:15');
/*!40000 ALTER TABLE `moment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键 ID',
  `email` varchar(100) NOT NULL COMMENT '邮箱（注册账号）',
  `password` varchar(100) NOT NULL COMMENT '密码（明文存储）',
  `nickname` varchar(50) DEFAULT NULL COMMENT '昵称',
  `permission` tinyint NOT NULL DEFAULT '1' COMMENT '权限：1=默认用户，0=管理员',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,'admin@test.com','admin123','管理员',0,'2026-11-11 08:50:58','2026-11-11 08:50:58'),(2,'111@qq.com','123456','111',0,'2026-11-11 08:55:19','2026-11-11 08:57:59');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'user_db'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-11  9:41:43
