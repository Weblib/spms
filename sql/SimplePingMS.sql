-- phpMyAdmin SQL Dump
-- version 3.3.7deb7
-- http://www.phpmyadmin.net
--
-- Serveur: localhost
-- Généré le : Mer 20 Mars 2013 à 18:27
-- Version du serveur: 5.1.66
-- Version de PHP: 5.3.3-7+squeeze14

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Base de données: `SimplePingMS`
--

-- --------------------------------------------------------

--
-- Structure de la table `Data_Report`
--

CREATE TABLE IF NOT EXISTS `Data_Report` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `host_id` int(11) NOT NULL,
  `host_type` int(11) DEFAULT NULL,
  `host_group` int(11) DEFAULT NULL,
  `report_date` datetime NOT NULL,
  `status` int(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `host_id` (`host_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=901916 ;

-- --------------------------------------------------------

--
-- Structure de la table `Host`
--

CREATE TABLE IF NOT EXISTS `Host` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `host_group` int(11) DEFAULT NULL,
  `host_type` int(11) DEFAULT NULL,
  `parent_host` int(11) DEFAULT NULL,
  `host_name` varchar(60) NOT NULL,
  `host_alias` varchar(40) NOT NULL,
  `host_address` varchar(40) DEFAULT NULL,
  `host_status` int(2) NOT NULL DEFAULT '0' COMMENT '0 :down, 1 : up, 2 : unreachable, 3 disabled',
  PRIMARY KEY (`id`),
  UNIQUE KEY `host_name` (`host_name`,`host_alias`,`host_address`),
  KEY `parent_host` (`parent_host`),
  KEY `host_type` (`host_type`),
  KEY `host_group` (`host_group`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=459 ;

-- --------------------------------------------------------

--
-- Structure de la table `Host_Group`
--

CREATE TABLE IF NOT EXISTS `Host_Group` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `group_name` varchar(40) NOT NULL,
  `parent_group` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `parent_group` (`parent_group`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=54 ;

-- --------------------------------------------------------

--
-- Structure de la table `Host_Type`
--

CREATE TABLE IF NOT EXISTS `Host_Type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(40) NOT NULL,
  `Desc` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=8 ;

--
-- Contraintes pour les tables exportées
--

--
-- Contraintes pour la table `Data_Report`
--
ALTER TABLE `Data_Report`
  ADD CONSTRAINT `Data_Report_ibfk_3` FOREIGN KEY (`host_id`) REFERENCES `Host` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Contraintes pour la table `Host`
--
ALTER TABLE `Host`
  ADD CONSTRAINT `Host_ibfk_1` FOREIGN KEY (`host_group`) REFERENCES `Host_Group` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `Host_ibfk_2` FOREIGN KEY (`host_type`) REFERENCES `Host_Type` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `Host_ibfk_3` FOREIGN KEY (`parent_host`) REFERENCES `Host` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Contraintes pour la table `Host_Group`
--
ALTER TABLE `Host_Group`
  ADD CONSTRAINT `Host_Group_ibfk_1` FOREIGN KEY (`parent_group`) REFERENCES `Host_Group` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;
