-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jun 23, 2025 at 01:11 PM
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
-- Table structure for table `admin_users`
--

CREATE TABLE `admin_users` (
  `id` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `role` enum('super_admin','admin','manager','support') NOT NULL,
  `permissions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`permissions`)),
  `is_active` tinyint(1) DEFAULT 1,
  `last_login` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `aircraft`
--

CREATE TABLE `aircraft` (
  `id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `registration_number` varchar(20) NOT NULL,
  `type` enum('helicopter','fixed_wing','jet') NOT NULL,
  `model` varchar(100) DEFAULT NULL,
  `manufacturer` varchar(100) DEFAULT NULL,
  `year_manufactured` year(4) DEFAULT NULL,
  `capacity` int(11) NOT NULL,
  `base_hourly_rate` decimal(10,2) NOT NULL,
  `repositioning_cost_per_km` decimal(8,2) DEFAULT NULL,
  `image_urls` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`image_urls`)),
  `image_public_ids` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`image_public_ids`)),
  `seat_plan_url` text DEFAULT NULL,
  `seat_plan_public_id` varchar(255) DEFAULT NULL,
  `amenities` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`amenities`)),
  `specifications` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`specifications`)),
  `is_available` tinyint(1) DEFAULT 1,
  `maintenance_status` enum('active','maintenance','retired') DEFAULT 'active',
  `created_by` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `aircraft_availability`
--

CREATE TABLE `aircraft_availability` (
  `id` varchar(255) NOT NULL,
  `aircraft_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `booking_id` varchar(255) DEFAULT NULL,
  `availability_type` enum('booked','maintenance','blocked','available') NOT NULL,
  `start_datetime` datetime NOT NULL,
  `end_datetime` datetime NOT NULL,
  `departure_location_id` int(11) DEFAULT NULL,
  `arrival_location_id` int(11) DEFAULT NULL,
  `repositioning_required` tinyint(1) DEFAULT 0,
  `repositioning_cost` decimal(10,2) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `booking_reference` varchar(100) DEFAULT NULL,
  `is_recurring` tinyint(1) DEFAULT 0,
  `recurrence_pattern` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`recurrence_pattern`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `id` varchar(255) NOT NULL,
  `user_id` varchar(255) NOT NULL,
  `company_id` int(11) NOT NULL,
  `aircraft_id` int(11) NOT NULL,
  `deal_id` varchar(255) DEFAULT NULL,
  `booking_type` enum('charter','deal','custom') NOT NULL,
  `service_type` enum('executive','sightseeing','tours','emergency','cargo') NOT NULL,
  `departure_location_id` int(11) NOT NULL,
  `arrival_location_id` int(11) NOT NULL,
  `departure_date` datetime NOT NULL,
  `return_date` datetime DEFAULT NULL,
  `is_round_trip` tinyint(1) DEFAULT 0,
  `passenger_count` int(11) NOT NULL,
  `base_amount` decimal(10,2) NOT NULL,
  `tax_amount` decimal(10,2) DEFAULT 0.00,
  `platform_commission` decimal(10,2) NOT NULL,
  `company_earnings` decimal(10,2) NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `special_requests` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`special_requests`)),
  `booking_status` enum('pending','confirmed','cancelled','completed') DEFAULT 'pending',
  `payment_status` enum('pending','paid','failed','refunded') DEFAULT 'pending',
  `confirmation_code` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `booking_history`
--

CREATE TABLE `booking_history` (
  `id` varchar(255) NOT NULL,
  `original_booking_id` varchar(255) NOT NULL,
  `user_id` varchar(255) NOT NULL,
  `aircraft_id` int(11) NOT NULL,
  `completion_date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `total_amount` decimal(10,2) NOT NULL,
  `rating` int(11) DEFAULT NULL CHECK (`rating` >= 1 and `rating` <= 5),
  `review` text DEFAULT NULL,
  `archived_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`archived_data`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `companies`
--

CREATE TABLE `companies` (
  `id` int(11) NOT NULL,
  `company_name` varchar(255) NOT NULL,
  `company_code` varchar(10) NOT NULL,
  `business_license` varchar(255) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `website_url` varchar(255) DEFAULT NULL,
  `logo_url` text DEFAULT NULL,
  `logo_public_id` varchar(255) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `country` varchar(100) DEFAULT NULL,
  `postal_code` varchar(20) DEFAULT NULL,
  `company_type` enum('airline','charter','broker') NOT NULL,
  `subscription_plan` enum('basic','premium','enterprise') DEFAULT 'basic',
  `commission_rate` decimal(5,2) DEFAULT 5.00,
  `is_active` tinyint(1) DEFAULT 1,
  `is_verified` tinyint(1) DEFAULT 0,
  `payment_details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`payment_details`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `company_payouts`
--

CREATE TABLE `company_payouts` (
  `id` varchar(255) NOT NULL,
  `company_id` int(11) NOT NULL,
  `payout_period_start` date NOT NULL,
  `payout_period_end` date NOT NULL,
  `total_bookings` int(11) NOT NULL,
  `gross_revenue` decimal(12,2) NOT NULL,
  `platform_commission` decimal(12,2) NOT NULL,
  `net_payout` decimal(12,2) NOT NULL,
  `currency` varchar(3) DEFAULT 'USD',
  `payout_status` enum('pending','processing','completed','failed') DEFAULT 'pending',
  `payout_method` enum('bank_transfer','paypal','stripe') NOT NULL,
  `payout_reference` varchar(255) DEFAULT NULL,
  `payout_date` timestamp NULL DEFAULT NULL,
  `booking_ids` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`booking_ids`)),
  `processed_by` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

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
-- Table structure for table `crew_members`
--

CREATE TABLE `crew_members` (
  `id` varchar(255) NOT NULL,
  `company_id` int(11) NOT NULL,
  `employee_id` varchar(50) NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `crew_type` enum('flight_attendant','co_pilot','engineer','security') NOT NULL,
  `certifications` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`certifications`)),
  `hourly_rate` decimal(10,2) NOT NULL,
  `availability_status` enum('available','assigned','off_duty','on_leave') DEFAULT 'available',
  `is_active` tinyint(1) DEFAULT 1,
  `hire_date` date NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `deals`
--

CREATE TABLE `deals` (
  `id` varchar(255) NOT NULL,
  `company_id` int(11) NOT NULL,
  `aircraft_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `deal_type` enum('charter','package','promotion') NOT NULL,
  `departure_location_id` int(11) NOT NULL,
  `arrival_location_id` int(11) NOT NULL,
  `departure_date` datetime DEFAULT NULL,
  `return_date` datetime DEFAULT NULL,
  `is_round_trip` tinyint(1) DEFAULT 0,
  `original_price` decimal(10,2) NOT NULL,
  `discounted_price` decimal(10,2) NOT NULL,
  `discount_percentage` decimal(5,2) DEFAULT NULL,
  `max_passengers` int(11) NOT NULL,
  `available_seats` int(11) NOT NULL,
  `deal_image_url` text DEFAULT NULL,
  `deal_image_public_id` varchar(255) DEFAULT NULL,
  `terms_conditions` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `valid_from` datetime NOT NULL,
  `valid_until` datetime NOT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `leases`
--

CREATE TABLE `leases` (
  `id` varchar(255) NOT NULL,
  `user_id` varchar(255) NOT NULL,
  `aircraft_id` int(11) NOT NULL,
  `lease_type` enum('wet_lease','dry_lease') NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `monthly_rate` decimal(12,2) NOT NULL,
  `total_amount` decimal(12,2) NOT NULL,
  `lease_status` enum('pending','active','expired','terminated') DEFAULT 'pending',
  `documents` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`documents`)),
  `document_public_ids` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`document_public_ids`)),
  `digital_signature_url` text DEFAULT NULL,
  `digital_signature_public_id` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `locations`
--

CREATE TABLE `locations` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `iata_code` varchar(3) DEFAULT NULL,
  `icao_code` varchar(4) DEFAULT NULL,
  `city` varchar(100) NOT NULL,
  `country` varchar(100) NOT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `timezone` varchar(50) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `loyalty_transactions`
--

CREATE TABLE `loyalty_transactions` (
  `id` varchar(255) NOT NULL,
  `user_id` varchar(255) NOT NULL,
  `transaction_type` enum('earned','redeemed','expired','bonus') NOT NULL,
  `points` int(11) NOT NULL,
  `booking_id` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` varchar(255) NOT NULL,
  `user_id` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `notification_type` enum('booking','payment','promotion','system') NOT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `sent_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `read_at` timestamp NULL DEFAULT NULL,
  `fcm_token` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

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
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `id` varchar(255) NOT NULL,
  `booking_id` varchar(255) NOT NULL,
  `user_id` varchar(255) NOT NULL,
  `company_id` int(11) NOT NULL,
  `payment_method` enum('card','mpesa','wallet') NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `platform_fee` decimal(10,2) NOT NULL,
  `company_amount` decimal(10,2) NOT NULL,
  `currency` varchar(3) DEFAULT 'USD',
  `transaction_id` varchar(255) DEFAULT NULL,
  `payment_status` enum('pending','completed','failed','refunded') DEFAULT 'pending',
  `payment_gateway_response` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`payment_gateway_response`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
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
-- Table structure for table `pilot_calendar_events`
--

CREATE TABLE `pilot_calendar_events` (
  `id` varchar(255) NOT NULL,
  `pilot_id` varchar(255) NOT NULL,
  `company_id` int(11) NOT NULL,
  `assignment_id` varchar(255) DEFAULT NULL,
  `booking_id` varchar(255) DEFAULT NULL,
  `event_type` enum('flight','training','medical','vacation','maintenance','standby') NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `start_datetime` datetime NOT NULL,
  `end_datetime` datetime NOT NULL,
  `location` varchar(255) DEFAULT NULL,
  `aircraft_registration` varchar(20) DEFAULT NULL,
  `flight_route` varchar(255) DEFAULT NULL,
  `duty_hours` decimal(4,2) DEFAULT NULL,
  `flight_hours` decimal(4,2) DEFAULT NULL,
  `event_status` enum('scheduled','confirmed','completed','cancelled') DEFAULT 'scheduled',
  `reminder_minutes` int(11) DEFAULT 120,
  `is_reminder_sent` tinyint(1) DEFAULT 0,
  `notes` text DEFAULT NULL,
  `created_by` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pilot_payments`
--

CREATE TABLE `pilot_payments` (
  `id` varchar(255) NOT NULL,
  `pilot_id` varchar(255) NOT NULL,
  `company_id` int(11) NOT NULL,
  `assignment_id` varchar(255) DEFAULT NULL,
  `payment_period_start` date NOT NULL,
  `payment_period_end` date NOT NULL,
  `base_hours` decimal(6,2) NOT NULL,
  `overtime_hours` decimal(6,2) DEFAULT 0.00,
  `base_pay` decimal(10,2) NOT NULL,
  `overtime_pay` decimal(10,2) DEFAULT 0.00,
  `bonus_amount` decimal(10,2) DEFAULT 0.00,
  `deductions` decimal(10,2) DEFAULT 0.00,
  `gross_pay` decimal(10,2) NOT NULL,
  `tax_deductions` decimal(10,2) DEFAULT 0.00,
  `net_pay` decimal(10,2) NOT NULL,
  `currency` varchar(3) DEFAULT 'USD',
  `payment_status` enum('pending','processed','paid','failed') DEFAULT 'pending',
  `payment_method` enum('bank_transfer','check','cash') NOT NULL,
  `payment_reference` varchar(255) DEFAULT NULL,
  `payment_date` timestamp NULL DEFAULT NULL,
  `payment_notes` text DEFAULT NULL,
  `processed_by` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rates`
--

CREATE TABLE `rates` (
  `id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `aircraft_id` int(11) NOT NULL,
  `rate_type` enum('hourly','daily','charter','lease') NOT NULL,
  `base_rate` decimal(10,2) NOT NULL,
  `peak_rate` decimal(10,2) DEFAULT NULL,
  `off_peak_rate` decimal(10,2) DEFAULT NULL,
  `currency` varchar(3) DEFAULT 'USD',
  `effective_from` date NOT NULL,
  `effective_to` date DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_by` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `super_admins`
--

CREATE TABLE `super_admins` (
  `id` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `role` enum('super_admin','platform_admin','support_admin') NOT NULL,
  `permissions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`permissions`)),
  `is_active` tinyint(1) DEFAULT 1,
  `last_login` timestamp NULL DEFAULT NULL,
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
  `loyalty_points` int(11) DEFAULT 0,
  `wallet_balance` decimal(10,2) DEFAULT 0.00,
  `is_active` tinyint(1) DEFAULT 1,
  `email_verified` tinyint(1) DEFAULT 0,
  `phone_verified` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

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
-- Indexes for table `admin_users`
--
ALTER TABLE `admin_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `aircraft`
--
ALTER TABLE `aircraft`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `registration_number` (`registration_number`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_aircraft_company_id` (`company_id`),
  ADD KEY `idx_aircraft_type` (`type`),
  ADD KEY `idx_aircraft_available` (`is_available`);

--
-- Indexes for table `aircraft_availability`
--
ALTER TABLE `aircraft_availability`
  ADD PRIMARY KEY (`id`),
  ADD KEY `booking_id` (`booking_id`),
  ADD KEY `departure_location_id` (`departure_location_id`),
  ADD KEY `arrival_location_id` (`arrival_location_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_aircraft_availability_aircraft` (`aircraft_id`),
  ADD KEY `idx_aircraft_availability_dates` (`start_datetime`,`end_datetime`),
  ADD KEY `idx_aircraft_availability_type` (`availability_type`),
  ADD KEY `idx_aircraft_availability_company` (`company_id`);

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `confirmation_code` (`confirmation_code`),
  ADD KEY `aircraft_id` (`aircraft_id`),
  ADD KEY `deal_id` (`deal_id`),
  ADD KEY `departure_location_id` (`departure_location_id`),
  ADD KEY `arrival_location_id` (`arrival_location_id`),
  ADD KEY `idx_bookings_user_id` (`user_id`),
  ADD KEY `idx_bookings_company_id` (`company_id`),
  ADD KEY `idx_bookings_departure_date` (`departure_date`),
  ADD KEY `idx_bookings_status` (`booking_status`);

--
-- Indexes for table `booking_history`
--
ALTER TABLE `booking_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `aircraft_id` (`aircraft_id`);

--
-- Indexes for table `companies`
--
ALTER TABLE `companies`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `company_code` (`company_code`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `business_license` (`business_license`);

--
-- Indexes for table `company_payouts`
--
ALTER TABLE `company_payouts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `company_id` (`company_id`),
  ADD KEY `processed_by` (`processed_by`);

--
-- Indexes for table `company_users`
--
ALTER TABLE `company_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `company_id` (`company_id`);

--
-- Indexes for table `crew_members`
--
ALTER TABLE `crew_members`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_company_employee` (`company_id`,`employee_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_crew_members_company` (`company_id`),
  ADD KEY `idx_crew_members_type` (`crew_type`);

--
-- Indexes for table `deals`
--
ALTER TABLE `deals`
  ADD PRIMARY KEY (`id`),
  ADD KEY `aircraft_id` (`aircraft_id`),
  ADD KEY `departure_location_id` (`departure_location_id`),
  ADD KEY `arrival_location_id` (`arrival_location_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_deals_company_id` (`company_id`),
  ADD KEY `idx_deals_valid_dates` (`valid_from`,`valid_until`);

--
-- Indexes for table `leases`
--
ALTER TABLE `leases`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `aircraft_id` (`aircraft_id`);

--
-- Indexes for table `locations`
--
ALTER TABLE `locations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `iata_code` (`iata_code`),
  ADD UNIQUE KEY `icao_code` (`icao_code`),
  ADD KEY `idx_locations_iata` (`iata_code`),
  ADD KEY `idx_locations_city` (`city`);

--
-- Indexes for table `loyalty_transactions`
--
ALTER TABLE `loyalty_transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `booking_id` (`booking_id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_notifications_user_id` (`user_id`),
  ADD KEY `idx_notifications_read` (`is_read`);

--
-- Indexes for table `passengers`
--
ALTER TABLE `passengers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `booking_id` (`booking_id`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `transaction_id` (`transaction_id`),
  ADD KEY `booking_id` (`booking_id`),
  ADD KEY `idx_payments_user_id` (`user_id`),
  ADD KEY `idx_payments_company_id` (`company_id`),
  ADD KEY `idx_payments_status` (`payment_status`);

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
-- Indexes for table `pilot_calendar_events`
--
ALTER TABLE `pilot_calendar_events`
  ADD PRIMARY KEY (`id`),
  ADD KEY `assignment_id` (`assignment_id`),
  ADD KEY `booking_id` (`booking_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_pilot_calendar_pilot_id` (`pilot_id`),
  ADD KEY `idx_pilot_calendar_company_id` (`company_id`),
  ADD KEY `idx_pilot_calendar_date` (`start_datetime`),
  ADD KEY `idx_pilot_calendar_status` (`event_status`),
  ADD KEY `idx_pilot_calendar_type` (`event_type`);

--
-- Indexes for table `pilot_payments`
--
ALTER TABLE `pilot_payments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `assignment_id` (`assignment_id`),
  ADD KEY `processed_by` (`processed_by`),
  ADD KEY `idx_pilot_payments_pilot` (`pilot_id`),
  ADD KEY `idx_pilot_payments_company` (`company_id`),
  ADD KEY `idx_pilot_payments_status` (`payment_status`);

--
-- Indexes for table `rates`
--
ALTER TABLE `rates`
  ADD PRIMARY KEY (`id`),
  ADD KEY `company_id` (`company_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_rates_aircraft` (`aircraft_id`);

--
-- Indexes for table `super_admins`
--
ALTER TABLE `super_admins`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `phone_number` (`phone_number`);

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
-- AUTO_INCREMENT for table `aircraft`
--
ALTER TABLE `aircraft`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `companies`
--
ALTER TABLE `companies`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `locations`
--
ALTER TABLE `locations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `passengers`
--
ALTER TABLE `passengers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rates`
--
ALTER TABLE `rates`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `aircraft`
--
ALTER TABLE `aircraft`
  ADD CONSTRAINT `aircraft_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `aircraft_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `company_users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `aircraft_availability`
--
ALTER TABLE `aircraft_availability`
  ADD CONSTRAINT `aircraft_availability_ibfk_1` FOREIGN KEY (`aircraft_id`) REFERENCES `aircraft` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `aircraft_availability_ibfk_2` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `aircraft_availability_ibfk_3` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `aircraft_availability_ibfk_4` FOREIGN KEY (`departure_location_id`) REFERENCES `locations` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `aircraft_availability_ibfk_5` FOREIGN KEY (`arrival_location_id`) REFERENCES `locations` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `aircraft_availability_ibfk_6` FOREIGN KEY (`created_by`) REFERENCES `company_users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `bookings_ibfk_2` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  ADD CONSTRAINT `bookings_ibfk_3` FOREIGN KEY (`aircraft_id`) REFERENCES `aircraft` (`id`),
  ADD CONSTRAINT `bookings_ibfk_4` FOREIGN KEY (`deal_id`) REFERENCES `deals` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `bookings_ibfk_5` FOREIGN KEY (`departure_location_id`) REFERENCES `locations` (`id`),
  ADD CONSTRAINT `bookings_ibfk_6` FOREIGN KEY (`arrival_location_id`) REFERENCES `locations` (`id`);

--
-- Constraints for table `booking_history`
--
ALTER TABLE `booking_history`
  ADD CONSTRAINT `booking_history_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `booking_history_ibfk_2` FOREIGN KEY (`aircraft_id`) REFERENCES `aircraft` (`id`);

--
-- Constraints for table `company_payouts`
--
ALTER TABLE `company_payouts`
  ADD CONSTRAINT `company_payouts_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  ADD CONSTRAINT `company_payouts_ibfk_2` FOREIGN KEY (`processed_by`) REFERENCES `super_admins` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `company_users`
--
ALTER TABLE `company_users`
  ADD CONSTRAINT `company_users_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `crew_members`
--
ALTER TABLE `crew_members`
  ADD CONSTRAINT `crew_members_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `crew_members_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `company_users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `deals`
--
ALTER TABLE `deals`
  ADD CONSTRAINT `deals_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `deals_ibfk_2` FOREIGN KEY (`aircraft_id`) REFERENCES `aircraft` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `deals_ibfk_3` FOREIGN KEY (`departure_location_id`) REFERENCES `locations` (`id`),
  ADD CONSTRAINT `deals_ibfk_4` FOREIGN KEY (`arrival_location_id`) REFERENCES `locations` (`id`),
  ADD CONSTRAINT `deals_ibfk_5` FOREIGN KEY (`created_by`) REFERENCES `company_users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `leases`
--
ALTER TABLE `leases`
  ADD CONSTRAINT `leases_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `leases_ibfk_2` FOREIGN KEY (`aircraft_id`) REFERENCES `aircraft` (`id`);

--
-- Constraints for table `loyalty_transactions`
--
ALTER TABLE `loyalty_transactions`
  ADD CONSTRAINT `loyalty_transactions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `loyalty_transactions_ibfk_2` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `passengers`
--
ALTER TABLE `passengers`
  ADD CONSTRAINT `passengers_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`),
  ADD CONSTRAINT `payments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `payments_ibfk_3` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`);

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
-- Constraints for table `pilot_calendar_events`
--
ALTER TABLE `pilot_calendar_events`
  ADD CONSTRAINT `pilot_calendar_events_ibfk_1` FOREIGN KEY (`pilot_id`) REFERENCES `pilots` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `pilot_calendar_events_ibfk_2` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `pilot_calendar_events_ibfk_3` FOREIGN KEY (`assignment_id`) REFERENCES `pilot_assignments` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `pilot_calendar_events_ibfk_4` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `pilot_calendar_events_ibfk_5` FOREIGN KEY (`created_by`) REFERENCES `company_users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `pilot_payments`
--
ALTER TABLE `pilot_payments`
  ADD CONSTRAINT `pilot_payments_ibfk_1` FOREIGN KEY (`pilot_id`) REFERENCES `pilots` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `pilot_payments_ibfk_2` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `pilot_payments_ibfk_3` FOREIGN KEY (`assignment_id`) REFERENCES `pilot_assignments` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `pilot_payments_ibfk_4` FOREIGN KEY (`processed_by`) REFERENCES `company_users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `rates`
--
ALTER TABLE `rates`
  ADD CONSTRAINT `rates_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `rates_ibfk_2` FOREIGN KEY (`aircraft_id`) REFERENCES `aircraft` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `rates_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `company_users` (`id`) ON DELETE SET NULL;

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
