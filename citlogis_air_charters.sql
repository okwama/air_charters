-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jul 10, 2025 at 04:32 PM
-- Server version: 10.6.22-MariaDB-cll-lve
-- PHP Version: 8.3.22

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `citlogis_air_charters`
--

-- --------------------------------------------------------

--
-- Table structure for table `adminNotifications`
--

CREATE TABLE `adminNotifications` (
  `id` int(11) NOT NULL,
  `target` enum('superadmin','citAdmin','companyAdmin','agent') NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `read` tinyint(1) DEFAULT 0,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `userId` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `adminNotifications`
--

INSERT INTO `adminNotifications` (`id`, `target`, `title`, `message`, `read`, `createdAt`, `updatedAt`, `userId`) VALUES
(27, 'citAdmin', 'Company approved', 'Company \"company b\" has been approved by Bob. ', 1, '2025-07-06 17:08:51', '2025-07-06 17:19:26', 2),
(40, 'agent', 'Company approved', 'Company \"aib company\" you onboarded has been approved', 0, '2025-07-07 08:02:01', '2025-07-07 08:02:01', 3),
(48, 'agent', 'Company submitted for review', 'jimmy, your charter company \"Flight abc\" has been submitted for review.', 1, '2025-07-08 10:58:01', '2025-07-09 09:44:38', 20),
(50, 'agent', 'Company approved', 'Company \"Flight abc\" you onboarded has been approved', 1, '2025-07-08 10:59:48', '2025-07-09 09:44:37', 20),
(51, 'companyAdmin', 'Company approved', 'Your company \"Flight abc\" has been approved', 1, '2025-07-08 10:59:48', '2025-07-08 11:02:43', 23),
(52, 'agent', 'Company submitted for review', 'jimmy, your charter company \"AIB flight\" has been submitted for review.', 0, '2025-07-10 13:54:48', '2025-07-10 13:54:48', 20),
(53, 'superadmin', 'New charter company awaiting review', 'Company \"AIB flight\" has been submitted by jimmy.', 0, '2025-07-10 13:54:48', '2025-07-10 13:54:48', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `agent_details`
--

CREATE TABLE `agent_details` (
  `id` int(11) NOT NULL,
  `adminId` int(11) NOT NULL,
  `imageUrl` varchar(255) DEFAULT NULL,
  `imagePublicIdUrl` varchar(255) DEFAULT NULL,
  `licenseUrl` varchar(255) DEFAULT NULL,
  `licensePublicIdUrl` varchar(255) DEFAULT NULL,
  `agreementFormUrl` varchar(255) DEFAULT NULL,
  `agreementFormPublicIdUrl` varchar(255) DEFAULT NULL,
  `idPassportNumber` varchar(255) DEFAULT NULL,
  `mobileNumber` varchar(255) DEFAULT NULL,
  `aocNumber` varchar(255) DEFAULT NULL,
  `companyName` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `agent_details`
--

INSERT INTO `agent_details` (`id`, `adminId`, `imageUrl`, `imagePublicIdUrl`, `licenseUrl`, `licensePublicIdUrl`, `agreementFormUrl`, `agreementFormPublicIdUrl`, `idPassportNumber`, `mobileNumber`, `aocNumber`, `companyName`, `country`, `createdAt`, `updatedAt`) VALUES
(4, 13, 'https://res.cloudinary.com/otienobryan/image/upload/v1751949896/charters_agents/ag_0bfcc53b-293e-44f6-9039-6b01e0f095f1/profile/dblxnd3x3aeadzovx9j1.png', 'charters_agents/ag_0bfcc53b-293e-44f6-9039-6b01e0f095f1/profile/dblxnd3x3aeadzovx9j1', 'https://res.cloudinary.com/otienobryan/image/upload/v1751949897/charters_agents/ag_0bfcc53b-293e-44f6-9039-6b01e0f095f1/license/jyajs91agov4kpkly7pn.pdf', 'charters_agents/ag_0bfcc53b-293e-44f6-9039-6b01e0f095f1/license/jyajs91agov4kpkly7pn', 'https://res.cloudinary.com/otienobryan/image/upload/v1751949898/charters_agents/ag_0bfcc53b-293e-44f6-9039-6b01e0f095f1/agreement/ekmvbp1wewe7upychttm.pdf', 'charters_agents/ag_0bfcc53b-293e-44f6-9039-6b01e0f095f1/agreement/ekmvbp1wewe7upychttm', '46464664', '0746466464', 'GDGGD46', 'Flight 54', 'Uganda', '2025-07-08 04:44:59', '2025-07-08 04:44:59'),
(5, 20, 'https://res.cloudinary.com/otienobryan/image/upload/v1751966114/charters_agents/ag_67c4cdf9-fe40-4da2-a7a3-e819ed03a4c1/profile/wkgcny5ltg4jii6anofn.jpg', 'charters_agents/ag_67c4cdf9-fe40-4da2-a7a3-e819ed03a4c1/profile/wkgcny5ltg4jii6anofn', 'https://res.cloudinary.com/otienobryan/image/upload/v1751966115/charters_agents/ag_67c4cdf9-fe40-4da2-a7a3-e819ed03a4c1/license/u9gbptkaju7q8ry4mqfw.pdf', 'charters_agents/ag_67c4cdf9-fe40-4da2-a7a3-e819ed03a4c1/license/u9gbptkaju7q8ry4mqfw', 'https://res.cloudinary.com/otienobryan/image/upload/v1751966116/charters_agents/ag_67c4cdf9-fe40-4da2-a7a3-e819ed03a4c1/agreement/qvnnpkwuzg5rmelnnnsy.pdf', 'charters_agents/ag_67c4cdf9-fe40-4da2-a7a3-e819ed03a4c1/agreement/qvnnpkwuzg5rmelnnnsy', '44646464', '575757575', '46464et', 'flight54', 'Uganda', '2025-07-08 09:15:17', '2025-07-08 09:15:17');

-- --------------------------------------------------------

--
-- Table structure for table `aircrafts`
--

CREATE TABLE `aircrafts` (
  `id` int(11) NOT NULL,
  `companyId` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `registrationNumber` varchar(20) NOT NULL,
  `type` enum('helicopter','fixedWing','jet','glider','seaplane','ultralight','balloon','tiltrotor','gyroplane','airship') NOT NULL,
  `model` varchar(100) DEFAULT NULL,
  `manufacturer` varchar(100) DEFAULT NULL,
  `yearManufactured` int(11) DEFAULT NULL,
  `capacity` int(11) NOT NULL,
  `isAvailable` tinyint(1) DEFAULT 1,
  `maintenanceStatus` enum('operational','maintenance','out_of_service') DEFAULT 'operational',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `aircrafts`
--

INSERT INTO `aircrafts` (`id`, `companyId`, `name`, `registrationNumber`, `type`, `model`, `manufacturer`, `yearManufactured`, `capacity`, `isAvailable`, `maintenanceStatus`, `createdAt`, `updatedAt`) VALUES
(1, 9, 'Citation Mustang', '5Y-MST001', 'jet', '510', 'Cessna', 2017, 11, 1, 'operational', '2025-07-10 04:55:02', '2025-07-10 09:29:52'),
(2, 9, 'Robinson R44 Raven II', '5Y-HEL001', 'helicopter', 'R44 Raven II', 'Robinson Helicopter Company', 2015, 9, 1, 'operational', '2025-07-10 08:23:25', '2025-07-10 09:29:10'),
(3, 9, 'Cessna 208 Caravan', '5Y-FIX001', 'fixedWing', '208B Grand Caravan EX', 'Cessna', 2013, 13, 1, 'operational', '2025-07-10 08:27:04', '2025-07-10 09:29:39');

-- --------------------------------------------------------

--
-- Table structure for table `aircraft_images`
--

CREATE TABLE `aircraft_images` (
  `id` int(11) NOT NULL,
  `aircraftId` int(11) NOT NULL,
  `category` varchar(50) NOT NULL,
  `url` text NOT NULL,
  `publicId` varchar(255) NOT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `aircraft_images`
--

INSERT INTO `aircraft_images` (`id`, `aircraftId`, `category`, `url`, `publicId`, `createdAt`, `updatedAt`) VALUES
(1, 1, 'exterior', 'https://res.cloudinary.com/otienobryan/image/upload/v1752123297/aircrafts/ac_44f57c7c-7412-41e5-8bea-55cfe9977269/exterior/cojlt2bxrbmpom5fwl7k.webp', 'aircrafts/ac_44f57c7c-7412-41e5-8bea-55cfe9977269/exterior/cojlt2bxrbmpom5fwl7k', '2025-07-10 04:55:02', '2025-07-10 04:55:02'),
(2, 1, 'interior', 'https://res.cloudinary.com/otienobryan/image/upload/v1752123299/aircrafts/ac_44f57c7c-7412-41e5-8bea-55cfe9977269/interior/zsbvcr1bzrlroocdgu7a.webp', 'aircrafts/ac_44f57c7c-7412-41e5-8bea-55cfe9977269/interior/zsbvcr1bzrlroocdgu7a', '2025-07-10 04:55:02', '2025-07-10 04:55:02'),
(3, 1, 'cockpit', 'https://res.cloudinary.com/otienobryan/image/upload/v1752123300/aircrafts/ac_44f57c7c-7412-41e5-8bea-55cfe9977269/cockpit/dr0i6rq8hcnjrqzqmrni.jpg', 'aircrafts/ac_44f57c7c-7412-41e5-8bea-55cfe9977269/cockpit/dr0i6rq8hcnjrqzqmrni', '2025-07-10 04:55:02', '2025-07-10 04:55:02'),
(4, 1, 'seating', 'https://res.cloudinary.com/otienobryan/image/upload/v1752123301/aircrafts/ac_44f57c7c-7412-41e5-8bea-55cfe9977269/seating/itdwbgtmussibtgfbdtr.webp', 'aircrafts/ac_44f57c7c-7412-41e5-8bea-55cfe9977269/seating/itdwbgtmussibtgfbdtr', '2025-07-10 04:55:02', '2025-07-10 04:55:02'),
(5, 2, 'exterior', 'https://res.cloudinary.com/otienobryan/image/upload/v1752156932/aircrafts/ac_f8ef8e88-5c6b-4690-8642-0cee097b6f75/exterior/stqajhzqpjygw9jknkak.webp', 'aircrafts/ac_f8ef8e88-5c6b-4690-8642-0cee097b6f75/exterior/stqajhzqpjygw9jknkak', '2025-07-10 08:23:25', '2025-07-10 14:15:33'),
(6, 2, 'interior', 'https://res.cloudinary.com/otienobryan/image/upload/v1752135802/aircrafts/ac_5f3d877b-8f91-4d97-9c14-205257dc54fa/interior/g4kzcutqqhzxbdiawlnt.webp', 'aircrafts/ac_5f3d877b-8f91-4d97-9c14-205257dc54fa/interior/g4kzcutqqhzxbdiawlnt', '2025-07-10 08:23:25', '2025-07-10 08:23:25'),
(7, 2, 'cockpit', 'https://res.cloudinary.com/otienobryan/image/upload/v1752135803/aircrafts/ac_5f3d877b-8f91-4d97-9c14-205257dc54fa/cockpit/wrqqlxsjoyj8fbswmf5u.webp', 'aircrafts/ac_5f3d877b-8f91-4d97-9c14-205257dc54fa/cockpit/wrqqlxsjoyj8fbswmf5u', '2025-07-10 08:23:25', '2025-07-10 08:23:25'),
(8, 2, 'seating', 'https://res.cloudinary.com/otienobryan/image/upload/v1752135804/aircrafts/ac_5f3d877b-8f91-4d97-9c14-205257dc54fa/seating/uhfve2v6h6mxd4icsvho.webp', 'aircrafts/ac_5f3d877b-8f91-4d97-9c14-205257dc54fa/seating/uhfve2v6h6mxd4icsvho', '2025-07-10 08:23:25', '2025-07-10 08:23:25'),
(9, 3, 'exterior', 'https://res.cloudinary.com/otienobryan/image/upload/v1752136020/aircrafts/ac_b5db5cb0-82b2-4e64-b51a-806863d24c19/exterior/mtxaws74dp4mijodadil.webp', 'aircrafts/ac_b5db5cb0-82b2-4e64-b51a-806863d24c19/exterior/mtxaws74dp4mijodadil', '2025-07-10 08:27:04', '2025-07-10 08:27:04'),
(10, 3, 'interior', 'https://res.cloudinary.com/otienobryan/image/upload/v1752136021/aircrafts/ac_b5db5cb0-82b2-4e64-b51a-806863d24c19/interior/ur5ucaj8ncxxhmj01ysw.webp', 'aircrafts/ac_b5db5cb0-82b2-4e64-b51a-806863d24c19/interior/ur5ucaj8ncxxhmj01ysw', '2025-07-10 08:27:04', '2025-07-10 08:27:04'),
(11, 3, 'cockpit', 'https://res.cloudinary.com/otienobryan/image/upload/v1752136022/aircrafts/ac_b5db5cb0-82b2-4e64-b51a-806863d24c19/cockpit/i5nuyllgto5ryjjaeklx.webp', 'aircrafts/ac_b5db5cb0-82b2-4e64-b51a-806863d24c19/cockpit/i5nuyllgto5ryjjaeklx', '2025-07-10 08:27:04', '2025-07-10 08:27:04'),
(12, 3, 'seating', 'https://res.cloudinary.com/otienobryan/image/upload/v1752136023/aircrafts/ac_b5db5cb0-82b2-4e64-b51a-806863d24c19/seating/n3at2jycybkcxixwdmza.webp', 'aircrafts/ac_b5db5cb0-82b2-4e64-b51a-806863d24c19/seating/n3at2jycybkcxixwdmza', '2025-07-10 08:27:04', '2025-07-10 08:27:04');

-- --------------------------------------------------------

--
-- Table structure for table `charters_admins`
--

CREATE TABLE `charters_admins` (
  `id` int(11) NOT NULL,
  `firstName` varchar(255) NOT NULL,
  `middleName` varchar(255) DEFAULT NULL,
  `lastName` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `isDefaultPassword` tinyint(1) NOT NULL DEFAULT 1,
  `role` enum('citAdmin','superadmin','companyAdmin','agent') DEFAULT 'citAdmin',
  `companyId` int(11) DEFAULT NULL,
  `agentDetailsId` int(11) DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `charters_admins`
--

INSERT INTO `charters_admins` (`id`, `firstName`, `middleName`, `lastName`, `email`, `password`, `isDefaultPassword`, `role`, `companyId`, `agentDetailsId`, `status`, `createdAt`, `updatedAt`) VALUES
(1, 'Bob', NULL, 'Super', 'bob.superadmin@example.com', '$2b$10$vva6in6Pz0bOBfm/THPZpOjX0zsFMWoKijd0HqAN2o4qlPVydS6R.', 0, 'superadmin', NULL, NULL, 'active', '2025-07-04 06:43:47', '2025-07-08 10:56:49'),
(2, 'Alice', NULL, 'Cit', 'alice.citadmin@example.com', '$2b$10$EQTQK1/8Kz3i7PexSlp2reoZ4awTcRl3XrDZHtIdhmAxVGz6GAPfW', 1, 'citAdmin', NULL, NULL, 'inactive', '2025-07-04 06:49:19', '2025-07-04 06:49:19'),
(3, 'Dave', NULL, 'Agent', 'dave.agent@example.com', '$2b$10$Fmd5QbY.0DA1g3nwnSLt2u0l3D4j0U5fkkIfITk3tLoIsttHNbs/y', 1, 'agent', NULL, NULL, 'active', '2025-07-04 06:49:39', '2025-07-04 06:49:39'),
(4, 'Carol', NULL, 'Comp', 'carol.companyadmin@example.com', '$2b$10$MiPP08n6luE8/z5KEW0Jbu3fxzFuvuK9DaZP7j7rVQFtRm85o/uga', 1, 'companyAdmin', NULL, NULL, 'active', '2025-07-04 06:56:00', '2025-07-04 06:56:00'),
(13, 'Benny', '', 'Okwama', 'bennjiokwama@gmail.com', '$2b$10$Xn32xJfa3B9GJ2yDKpThSunJvn7GRHKK.yr.zCNe.jHM9fU3fKxP.', 1, 'agent', NULL, 4, 'active', '2025-07-08 04:44:59', '2025-07-08 04:44:59'),
(20, 'jimmy', '', 'gitere', 'gitere.dev@gmail.com', '$2b$10$2e38kJA3ZtvndVN4cm7t2eB5xxa8h8PDfVtLTJ7bOO9dJd4lzpCKG', 0, 'agent', NULL, 5, 'active', '2025-07-08 09:15:17', '2025-07-08 10:46:14'),
(23, 'Jimmy', NULL, 'Kalu', 'giterejames10@gmail.com', '$2b$10$xazAYZeDUYCRuG8eD2W4l.oqT7yR0FAeugPQWMRNzxKCZGnltb0GC', 0, 'companyAdmin', 9, NULL, 'active', '2025-07-08 10:59:48', '2025-07-08 11:01:26');

-- --------------------------------------------------------

--
-- Table structure for table `charters_companies`
--

CREATE TABLE `charters_companies` (
  `id` int(11) NOT NULL,
  `companyName` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `contactPersonFirstName` varchar(255) NOT NULL,
  `contactPersonLastName` varchar(255) NOT NULL,
  `mobileNumber` varchar(255) NOT NULL,
  `logo` varchar(255) DEFAULT NULL,
  `country` varchar(255) NOT NULL,
  `licenseNumber` varchar(255) NOT NULL,
  `license` varchar(255) DEFAULT NULL,
  `licensePublicId` varchar(255) DEFAULT NULL,
  `logoPublicId` varchar(255) DEFAULT NULL,
  `onboardedBy` varchar(255) NOT NULL,
  `adminId` int(11) NOT NULL,
  `status` enum('pendingReview','active','inactive','rejected','draft') NOT NULL DEFAULT 'draft',
  `agreementForm` varchar(255) DEFAULT NULL,
  `agreementFormPublicId` varchar(255) DEFAULT NULL,
  `approvedBy` varchar(255) DEFAULT NULL,
  `approvedAt` datetime DEFAULT NULL,
  `reviewRemarks` text DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `charters_companies`
--

INSERT INTO `charters_companies` (`id`, `companyName`, `email`, `contactPersonFirstName`, `contactPersonLastName`, `mobileNumber`, `logo`, `country`, `licenseNumber`, `license`, `licensePublicId`, `logoPublicId`, `onboardedBy`, `adminId`, `status`, `agreementForm`, `agreementFormPublicId`, `approvedBy`, `approvedAt`, `reviewRemarks`, `createdAt`, `updatedAt`) VALUES
(5, 'aib', 'aib@gmail.com', 'Alice', 'Kamau', '+254723456789', 'https://res.cloudinary.com/otienobryan/image/upload/v1751798157/charters_logos/sh7ytvzvaze7t9zsnljm.jpg', 'Kenya', 'GDGD4646', NULL, NULL, 'charters_logos/sh7ytvzvaze7t9zsnljm', 'Alice Cit', 19, 'draft', 'https://res.cloudinary.com/otienobryan/raw/upload/v1751808498/charters_documents/aib/aib_agreementForm.pdf', 'charters_documents/aib/aib_agreementForm.pdf', NULL, NULL, NULL, '2025-07-06 10:35:56', '2025-07-08 08:35:00'),
(6, 'company 1', 'company1@gmail.com', 'David', 'Omondi', '+256734567890', 'https://res.cloudinary.com/otienobryan/image/upload/v1751811095/charters_logos/bqeydvhkjiykfnfmwxyj.jpg', 'Uganda', 'DGDG384', NULL, NULL, 'charters_logos/bqeydvhkjiykfnfmwxyj', 'Dave Agent', 3, 'active', 'https://res.cloudinary.com/otienobryan/raw/upload/v1751811152/charters_documents/company_1/company_1_agreementForm.pdf', 'charters_documents/company_1/company_1_agreementForm.pdf', 'Bob Super', '2025-07-06 17:04:48', 'Successfully approved', '2025-07-06 14:11:33', '2025-07-06 17:04:48'),
(7, 'company b', 'companyb@gmail.com', 'Emily', 'Atieno', '+256745678901', 'https://res.cloudinary.com/otienobryan/image/upload/v1751813467/charters_logos/blx9th2dlpfspzgqhfvg.jpg', 'Uganda', 'GHDDH', NULL, NULL, 'charters_logos/blx9th2dlpfspzgqhfvg', 'Alice Cit', 2, 'active', 'https://res.cloudinary.com/otienobryan/raw/upload/v1751813490/charters_documents/company_b/company_b_agreementForm.pdf', 'charters_documents/company_b/company_b_agreementForm.pdf', 'Bob Super', '2025-07-06 17:08:51', 'Successfully approved', '2025-07-06 14:51:06', '2025-07-06 17:08:51'),
(9, 'Flight abc', 'giterejames10@gmail.com', 'Jimmy', 'Kalu', '48488484', 'https://res.cloudinary.com/otienobryan/image/upload/v1751967666/charters_logos/tr5hzvq6bs2o5kukucrq.webp', 'Uganda', '4747edhdh', 'https://res.cloudinary.com/otienobryan/raw/upload/v1751972277/charters_documents/flight_abc/flight_abc_license.pdf', 'charters_documents/flight_abc/flight_abc_license.pdf', 'charters_logos/tr5hzvq6bs2o5kukucrq', 'jimmy gitere', 20, 'active', 'https://res.cloudinary.com/otienobryan/raw/upload/v1751972264/charters_documents/flight_abc/flight_abc_agreementForm.pdf', 'charters_documents/flight_abc/flight_abc_agreementForm.pdf', 'Bob Super', '2025-07-08 10:59:48', 'Successfully approved', '2025-07-08 09:41:06', '2025-07-08 10:59:48'),
(10, 'AIB flight', 'contact@jamesgiteredev.site', 'peter', 'tim', '071236474747', 'https://res.cloudinary.com/otienobryan/image/upload/v1752155651/charters_logos/g4nobg2jvxyrirmzdur7.jpg', 'Kenya', 'FHFHDHD57', NULL, NULL, 'charters_logos/g4nobg2jvxyrirmzdur7', 'jimmy gitere', 20, 'pendingReview', 'https://res.cloudinary.com/otienobryan/raw/upload/v1752155683/charters_documents/aib_flight/aib_flight_agreementForm.pdf', 'charters_documents/aib_flight/aib_flight_agreementForm.pdf', NULL, NULL, NULL, '2025-07-10 13:54:11', '2025-07-10 13:54:48');

-- --------------------------------------------------------

--
-- Table structure for table `charter_deals`
--

CREATE TABLE `charter_deals` (
  `id` int(11) NOT NULL,
  `companyId` int(11) NOT NULL,
  `fixedRouteId` int(11) NOT NULL,
  `aircraftId` int(11) NOT NULL,
  `date` date NOT NULL,
  `time` time NOT NULL,
  `pricePerSeat` decimal(10,2) DEFAULT NULL,
  `discountPerSeat` int(11) DEFAULT 0,
  `priceFullCharter` decimal(10,2) DEFAULT NULL,
  `discountFullCharter` int(11) DEFAULT 0,
  `availableSeats` int(11) NOT NULL,
  `dealType` enum('privateCharter','jetSharing') NOT NULL DEFAULT 'privateCharter',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `charter_deals`
--

INSERT INTO `charter_deals` (`id`, `companyId`, `fixedRouteId`, `aircraftId`, `date`, `time`, `pricePerSeat`, `discountPerSeat`, `priceFullCharter`, `discountFullCharter`, `availableSeats`, `dealType`, `createdAt`, `updatedAt`) VALUES
(7, 9, 10, 1, '2025-07-11', '19:07:00', NULL, NULL, 3000.00, 5, 11, 'privateCharter', '2025-07-10 13:07:30', '2025-07-10 13:07:30'),
(8, 9, 9, 1, '2025-07-18', '20:20:00', NULL, NULL, 12000.00, 5, 11, 'privateCharter', '2025-07-10 13:20:49', '2025-07-10 13:20:49'),
(9, 9, 9, 2, '2025-07-23', '16:27:00', 50.00, 5, NULL, NULL, 9, 'jetSharing', '2025-07-10 13:25:09', '2025-07-10 13:25:09'),
(10, 9, 8, 2, '2025-07-23', '19:35:00', 50.00, 5, NULL, NULL, 9, 'jetSharing', '2025-07-10 13:35:36', '2025-07-10 13:35:36');

-- --------------------------------------------------------

--
-- Table structure for table `company_users`
--

CREATE TABLE `company_users` (
  `id` varchar(255) NOT NULL,
  `company_id` int(11) NOT NULL,
  `email` varchar(255) NOT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `role` enum('admin','manager','operator','finance') NOT NULL,
  `permissions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`permissions`)),
  `profile_image_url` text DEFAULT NULL,
  `profile_image_public_id` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `last_login` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `fixed_routes`
--

CREATE TABLE `fixed_routes` (
  `id` int(11) NOT NULL,
  `origin` varchar(50) NOT NULL,
  `destination` varchar(50) NOT NULL,
  `imageUrl` varchar(255) NOT NULL,
  `imagePublicId` varchar(255) NOT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `fixed_routes`
--

INSERT INTO `fixed_routes` (`id`, `origin`, `destination`, `imageUrl`, `imagePublicId`, `createdAt`, `updatedAt`) VALUES
(8, 'Nairobi', 'Diani', 'https://res.cloudinary.com/otienobryan/image/upload/v1752152652/fixed_route_images/snmysta57f0r8zpgmfiy.jpg', 'fixed_route_images/snmysta57f0r8zpgmfiy', '2025-07-10 13:04:12', '2025-07-10 13:04:12'),
(9, 'Nairobi', 'Mombasa', 'https://res.cloudinary.com/otienobryan/image/upload/v1752152680/fixed_route_images/qlndawmm9yagncbjohiz.jpg', 'fixed_route_images/qlndawmm9yagncbjohiz', '2025-07-10 13:04:40', '2025-07-10 13:04:40'),
(10, 'Nairobi', 'Kisumu', 'https://res.cloudinary.com/otienobryan/image/upload/v1752152728/fixed_route_images/hsco6s8nn8qszlgjs0bj.jpg', 'fixed_route_images/hsco6s8nn8qszlgjs0bj', '2025-07-10 13:05:28', '2025-07-10 13:05:28'),
(11, 'Kisumu', 'Nairobi', 'https://res.cloudinary.com/otienobryan/image/upload/v1752152756/fixed_route_images/earvgtnebhxdhydi6rc5.jpg', 'fixed_route_images/earvgtnebhxdhydi6rc5', '2025-07-10 13:05:55', '2025-07-10 13:05:55');

-- --------------------------------------------------------

--
-- Table structure for table `passengers`
--

CREATE TABLE `passengers` (
  `id` int(11) NOT NULL,
  `booking_id` varchar(255) NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `age` int(11) DEFAULT NULL,
  `nationality` varchar(100) DEFAULT NULL,
  `id_passport_number` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pilots`
--

CREATE TABLE `pilots` (
  `id` varchar(255) NOT NULL,
  `company_id` int(11) NOT NULL,
  `employee_id` varchar(50) NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `nationality` varchar(100) DEFAULT NULL,
  `profile_image_url` text DEFAULT NULL,
  `profile_image_public_id` varchar(255) DEFAULT NULL,
  `license_number` varchar(100) NOT NULL,
  `license_type` enum('private','commercial','airline_transport') NOT NULL,
  `license_expiry` date NOT NULL,
  `medical_certificate_expiry` date NOT NULL,
  `total_flight_hours` int(11) DEFAULT 0,
  `aircraft_type_ratings` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`aircraft_type_ratings`)),
  `certifications` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`certifications`)),
  `emergency_contact` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`emergency_contact`)),
  `base_hourly_rate` decimal(10,2) NOT NULL,
  `overtime_rate` decimal(10,2) DEFAULT NULL,
  `availability_status` enum('available','assigned','off_duty','on_leave') DEFAULT 'available',
  `is_active` tinyint(1) DEFAULT 1,
  `hire_date` date NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pilot_assignments`
--

CREATE TABLE `pilot_assignments` (
  `id` varchar(255) NOT NULL,
  `booking_id` varchar(255) NOT NULL,
  `company_id` int(11) NOT NULL,
  `pilot_id` varchar(255) NOT NULL,
  `co_pilot_id` varchar(255) DEFAULT NULL,
  `assignment_type` enum('captain','co_pilot','solo') NOT NULL,
  `assignment_status` enum('assigned','confirmed','completed','cancelled') DEFAULT 'assigned',
  `flight_hours` decimal(4,2) DEFAULT NULL,
  `duty_start_time` datetime NOT NULL,
  `duty_end_time` datetime NOT NULL,
  `pre_flight_briefing` tinyint(1) DEFAULT 0,
  `post_flight_report` text DEFAULT NULL,
  `assignment_notes` text DEFAULT NULL,
  `assigned_by` varchar(255) DEFAULT NULL,
  `assigned_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `confirmed_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` varchar(255) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `country_code` varchar(5) DEFAULT NULL,
  `profile_image_url` text DEFAULT NULL,
  `profile_image_public_id` varchar(255) DEFAULT NULL,
  `loyalty_points` int(11) NOT NULL DEFAULT 0,
  `wallet_balance` decimal(10,2) NOT NULL DEFAULT 0.00,
  `is_active` tinyint(4) NOT NULL DEFAULT 1,
  `email_verified` tinyint(4) NOT NULL DEFAULT 0,
  `phone_verified` tinyint(4) NOT NULL DEFAULT 0,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `updated_at` datetime(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6),
  `password` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `email`, `phone_number`, `first_name`, `last_name`, `country_code`, `profile_image_url`, `profile_image_public_id`, `loyalty_points`, `wallet_balance`, `is_active`, `email_verified`, `phone_verified`, `created_at`, `updated_at`, `password`) VALUES
('user_1752093294468_5lug3jt2p', 'bennjiokwama@gmail.com', NULL, 'Benjamin', 'Okwama', NULL, NULL, NULL, 0, 0.00, 1, 0, 0, '2025-07-09 22:34:53.214162', '2025-07-09 22:34:53.214162', '$2b$10$YG/eQ.GQqLJVO6RMWfTNre5xdJYw83bLPfDVGnB6.igvAj9Mv03YG'),
('user_1752097521091_cq7emunyt', 'test@example.com', '+1234567890', 'Jane', 'Smith', '+1', NULL, NULL, 0, 0.00, 1, 0, 0, '2025-07-09 23:45:19.955132', '2025-07-09 23:48:13.000000', '$2b$10$xoQehBjWpEra4v11su6nretZwxNySNq4NkUgG1bpNTmmq5n6qJTbC');

-- --------------------------------------------------------

--
-- Table structure for table `user_calendar_events`
--

CREATE TABLE `user_calendar_events` (
  `id` varchar(255) NOT NULL,
  `user_id` varchar(255) NOT NULL,
  `booking_id` varchar(255) DEFAULT NULL,
  `event_type` enum('flight','reminder','personal','travel_prep') NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `event_date` datetime NOT NULL,
  `end_date` datetime DEFAULT NULL,
  `is_all_day` tinyint(1) DEFAULT 0,
  `location` varchar(255) DEFAULT NULL,
  `reminder_minutes` int(11) DEFAULT 60,
  `is_reminder_sent` tinyint(1) DEFAULT 0,
  `event_color` varchar(7) DEFAULT '#007AFF',
  `is_recurring` tinyint(1) DEFAULT 0,
  `recurrence_pattern` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`recurrence_pattern`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_documents`
--

CREATE TABLE `user_documents` (
  `id` varchar(255) NOT NULL,
  `user_id` varchar(255) NOT NULL,
  `booking_id` varchar(255) DEFAULT NULL,
  `document_type` enum('receipt','ticket','invoice','boarding_pass','itinerary','other') NOT NULL,
  `document_name` varchar(255) NOT NULL,
  `document_url` text NOT NULL,
  `document_public_id` varchar(255) NOT NULL,
  `file_size` int(11) DEFAULT NULL,
  `file_format` varchar(10) DEFAULT NULL,
  `is_favorite` tinyint(1) DEFAULT 0,
  `tags` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`tags`)),
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_preferences`
--

CREATE TABLE `user_preferences` (
  `user_id` varchar(255) NOT NULL,
  `language` varchar(50) DEFAULT NULL,
  `currency` varchar(20) DEFAULT NULL,
  `notifications` tinyint(4) NOT NULL DEFAULT 1,
  `date_of_birth` date DEFAULT NULL,
  `nationality` varchar(100) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `updated_at` datetime(6) NOT NULL DEFAULT current_timestamp(6) ON UPDATE current_timestamp(6)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user_trip_history`
--

CREATE TABLE `user_trip_history` (
  `id` varchar(255) NOT NULL,
  `user_id` varchar(255) NOT NULL,
  `booking_id` varchar(255) NOT NULL,
  `company_id` int(11) NOT NULL,
  `aircraft_id` int(11) NOT NULL,
  `trip_status` enum('upcoming','completed','cancelled') NOT NULL,
  `departure_location_id` int(11) NOT NULL,
  `arrival_location_id` int(11) NOT NULL,
  `departure_date` datetime NOT NULL,
  `return_date` datetime DEFAULT NULL,
  `is_round_trip` tinyint(1) DEFAULT 0,
  `passenger_count` int(11) NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `payment_status` enum('paid','refunded','partial_refund') NOT NULL,
  `confirmation_code` varchar(50) NOT NULL,
  `aircraft_name` varchar(255) DEFAULT NULL,
  `aircraft_type` varchar(50) DEFAULT NULL,
  `company_name` varchar(255) DEFAULT NULL,
  `pilot_name` varchar(255) DEFAULT NULL,
  `flight_duration_minutes` int(11) DEFAULT NULL,
  `user_rating` int(11) DEFAULT NULL CHECK (`user_rating` >= 1 and `user_rating` <= 5),
  `user_review` text DEFAULT NULL,
  `trip_photos` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`trip_photos`)),
  `receipt_url` text DEFAULT NULL,
  `ticket_url` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `completed_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `adminNotifications`
--
ALTER TABLE `adminNotifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `userId` (`userId`);

--
-- Indexes for table `agent_details`
--
ALTER TABLE `agent_details`
  ADD PRIMARY KEY (`id`),
  ADD KEY `adminId` (`adminId`);

--
-- Indexes for table `aircrafts`
--
ALTER TABLE `aircrafts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `registrationNumber` (`registrationNumber`),
  ADD UNIQUE KEY `registrationNumber_2` (`registrationNumber`),
  ADD UNIQUE KEY `registrationNumber_3` (`registrationNumber`),
  ADD KEY `companyId` (`companyId`);

--
-- Indexes for table `aircraft_images`
--
ALTER TABLE `aircraft_images`
  ADD PRIMARY KEY (`id`),
  ADD KEY `aircraftId` (`aircraftId`);

--
-- Indexes for table `charters_admins`
--
ALTER TABLE `charters_admins`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `email_2` (`email`),
  ADD UNIQUE KEY `email_3` (`email`),
  ADD UNIQUE KEY `email_4` (`email`),
  ADD KEY `companyId` (`companyId`);

--
-- Indexes for table `charters_companies`
--
ALTER TABLE `charters_companies`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `charter_deals`
--
ALTER TABLE `charter_deals`
  ADD PRIMARY KEY (`id`),
  ADD KEY `companyId` (`companyId`),
  ADD KEY `fixedRouteId` (`fixedRouteId`),
  ADD KEY `aircraftId` (`aircraftId`);

--
-- Indexes for table `company_users`
--
ALTER TABLE `company_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `company_id` (`company_id`);

--
-- Indexes for table `fixed_routes`
--
ALTER TABLE `fixed_routes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `passengers`
--
ALTER TABLE `passengers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `booking_id` (`booking_id`);

--
-- Indexes for table `pilots`
--
ALTER TABLE `pilots`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `employee_id` (`employee_id`),
  ADD UNIQUE KEY `license_number` (`license_number`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_pilots_company_id` (`company_id`),
  ADD KEY `idx_pilots_availability` (`availability_status`),
  ADD KEY `idx_pilots_license_expiry` (`license_expiry`);

--
-- Indexes for table `pilot_assignments`
--
ALTER TABLE `pilot_assignments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `company_id` (`company_id`),
  ADD KEY `co_pilot_id` (`co_pilot_id`),
  ADD KEY `assigned_by` (`assigned_by`),
  ADD KEY `idx_pilot_assignments_booking` (`booking_id`),
  ADD KEY `idx_pilot_assignments_pilot` (`pilot_id`),
  ADD KEY `idx_pilot_assignments_status` (`assignment_status`),
  ADD KEY `idx_pilot_assignments_duty_start` (`duty_start_time`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `IDX_97672ac88f789774dd47f7c8be` (`email`),
  ADD UNIQUE KEY `IDX_17d1817f241f10a3dbafb169fd` (`phone_number`);

--
-- Indexes for table `user_calendar_events`
--
ALTER TABLE `user_calendar_events`
  ADD PRIMARY KEY (`id`),
  ADD KEY `booking_id` (`booking_id`),
  ADD KEY `idx_user_calendar_user_id` (`user_id`),
  ADD KEY `idx_user_calendar_date` (`event_date`),
  ADD KEY `idx_user_calendar_type` (`event_type`);

--
-- Indexes for table `user_documents`
--
ALTER TABLE `user_documents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_documents_user_id` (`user_id`),
  ADD KEY `idx_user_documents_type` (`document_type`),
  ADD KEY `idx_user_documents_booking` (`booking_id`);

--
-- Indexes for table `user_preferences`
--
ALTER TABLE `user_preferences`
  ADD PRIMARY KEY (`user_id`);

--
-- Indexes for table `user_trip_history`
--
ALTER TABLE `user_trip_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `booking_id` (`booking_id`),
  ADD KEY `company_id` (`company_id`),
  ADD KEY `aircraft_id` (`aircraft_id`),
  ADD KEY `departure_location_id` (`departure_location_id`),
  ADD KEY `arrival_location_id` (`arrival_location_id`),
  ADD KEY `idx_user_trip_history_user_id` (`user_id`),
  ADD KEY `idx_user_trip_history_status` (`trip_status`),
  ADD KEY `idx_user_trip_history_departure` (`departure_date`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `adminNotifications`
--
ALTER TABLE `adminNotifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=54;

--
-- AUTO_INCREMENT for table `agent_details`
--
ALTER TABLE `agent_details`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `aircrafts`
--
ALTER TABLE `aircrafts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `aircraft_images`
--
ALTER TABLE `aircraft_images`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `charters_admins`
--
ALTER TABLE `charters_admins`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `charters_companies`
--
ALTER TABLE `charters_companies`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `charter_deals`
--
ALTER TABLE `charter_deals`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `fixed_routes`
--
ALTER TABLE `fixed_routes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `passengers`
--
ALTER TABLE `passengers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `adminNotifications`
--
ALTER TABLE `adminNotifications`
  ADD CONSTRAINT `adminNotifications_ibfk_1` FOREIGN KEY (`userId`) REFERENCES `charters_admins` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `agent_details`
--
ALTER TABLE `agent_details`
  ADD CONSTRAINT `agent_details_ibfk_1` FOREIGN KEY (`adminId`) REFERENCES `charters_admins` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `aircrafts`
--
ALTER TABLE `aircrafts`
  ADD CONSTRAINT `aircrafts_ibfk_1` FOREIGN KEY (`companyId`) REFERENCES `charters_companies` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `aircraft_images`
--
ALTER TABLE `aircraft_images`
  ADD CONSTRAINT `aircraft_images_ibfk_1` FOREIGN KEY (`aircraftId`) REFERENCES `aircrafts` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `charters_admins`
--
ALTER TABLE `charters_admins`
  ADD CONSTRAINT `charters_admins_ibfk_1` FOREIGN KEY (`companyId`) REFERENCES `charters_companies` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `charter_deals`
--
ALTER TABLE `charter_deals`
  ADD CONSTRAINT `charter_deals_ibfk_1` FOREIGN KEY (`companyId`) REFERENCES `charters_companies` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `charter_deals_ibfk_2` FOREIGN KEY (`fixedRouteId`) REFERENCES `fixed_routes` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `charter_deals_ibfk_3` FOREIGN KEY (`aircraftId`) REFERENCES `aircrafts` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Constraints for table `company_users`
--
ALTER TABLE `company_users`
  ADD CONSTRAINT `company_users_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `passengers`
--
ALTER TABLE `passengers`
  ADD CONSTRAINT `passengers_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `pilots`
--
ALTER TABLE `pilots`
  ADD CONSTRAINT `pilots_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `pilots_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `company_users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `pilot_assignments`
--
ALTER TABLE `pilot_assignments`
  ADD CONSTRAINT `pilot_assignments_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `pilot_assignments_ibfk_2` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `pilot_assignments_ibfk_3` FOREIGN KEY (`pilot_id`) REFERENCES `pilots` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `pilot_assignments_ibfk_4` FOREIGN KEY (`co_pilot_id`) REFERENCES `pilots` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `pilot_assignments_ibfk_5` FOREIGN KEY (`assigned_by`) REFERENCES `company_users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `user_calendar_events`
--
ALTER TABLE `user_calendar_events`
  ADD CONSTRAINT `user_calendar_events_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_calendar_events_ibfk_2` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_documents`
--
ALTER TABLE `user_documents`
  ADD CONSTRAINT `user_documents_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_documents_ibfk_2` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `user_trip_history`
--
ALTER TABLE `user_trip_history`
  ADD CONSTRAINT `user_trip_history_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_trip_history_ibfk_2` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`),
  ADD CONSTRAINT `user_trip_history_ibfk_3` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  ADD CONSTRAINT `user_trip_history_ibfk_4` FOREIGN KEY (`aircraft_id`) REFERENCES `aircraft` (`id`),
  ADD CONSTRAINT `user_trip_history_ibfk_5` FOREIGN KEY (`departure_location_id`) REFERENCES `locations` (`id`),
  ADD CONSTRAINT `user_trip_history_ibfk_6` FOREIGN KEY (`arrival_location_id`) REFERENCES `locations` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
