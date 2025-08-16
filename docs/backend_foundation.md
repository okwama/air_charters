# 🚀 Phase 1: Backend Foundation - Implementation Plan

## 📱 Current Frontend Status (Updated)

### ✅ Recently Completed Frontend Features
- **Experiences & Tours System**: Complete tour booking platform with 9 categories
- **RenderFlex Overflow Fix**: Resolved layout issues in experience cards
- **Card Height Optimization**: Improved visual proportions and responsive design
- **Code Quality Improvements**: Fixed 46 linting issues and updated deprecated methods
- **Performance Optimization**: Better memory usage and layout calculations

### 🎯 Frontend Achievements
- Complete booking system with 6-step user journey
- Experiences platform with horizontal scrolling categories
- Professional UI/UX with modal navigation and form validation
- Payment integration with credit card forms and live preview
- Responsive design that works across different screen sizes

### 🔧 Technical Improvements
- Replaced fixed aspect ratios with flexible layouts
- Updated `withOpacity()` to `withValues()` for modern Flutter
- Implemented proper constraint handling to prevent overflow
- Optimized card heights and spacing for better visual balance

---

## Overview
This document outlines the complete implementation plan for establishing the backend foundation of the Air Charters Flutter application. This phase focuses on creating a robust, scalable backend architecture that will support all customer and admin features.

**Timeline:** 4-6 weeks  
**Priority:** High - Foundation for all other features

---

## 🎯 Phase 1 Objectives

### Core Goals
- [ ] Implement comprehensive API service layer
- [ ] Design and set up MySQL database schema
- [ ] Create data models for all entities
- [ ] Integrate Firebase authentication backend
- [ ] Add proper error handling and loading states
- [ ] Establish data persistence and caching strategies

### Success Criteria
- All API endpoints are functional and tested
- Database schema supports all planned features
- Authentication flow is fully integrated
- Error handling covers all failure scenarios
- Loading states provide excellent UX

---

## 📋 Implementation Roadmap

### Week 1-2: API Service Layer & Data Models
- [ ] Core API service architecture
- [ ] HTTP client configuration
- [ ] Request/response interceptors
- [ ] Data models for all entities
- [ ] API endpoint definitions

### Week 3-4: Database Schema & Firebase Integration
- [ ] MySQL database design
- [ ] Firebase authentication integration
- [ ] User session management
- [ ] Data synchronization strategies

### Week 5-6: Error Handling & Testing
- [ ] Comprehensive error handling
- [ ] Loading states implementation
- [ ] API testing and validation
- [ ] Performance optimization

---

## 🏗️ 1. API Service Layer Implementation

### 1.1 Core API Service Architecture

**File Structure:**
```
lib/core/network/
├── api_service.dart          # Main API service class
├── api_client.dart           # HTTP client configuration
├── api_endpoints.dart        # API endpoint constants
├── api_interceptors.dart     # Request/response interceptors
├── api_exceptions.dart       # Custom API exceptions
└── network_info.dart         # Network connectivity checker
```

### 1.2 API Endpoints Categories

**Customer Authentication Endpoints**
```dart
// Customer authentication and management
POST /api/auth/customer/register
POST /api/auth/customer/login
POST /api/auth/customer/verify-otp
POST /api/auth/customer/refresh-token
GET  /api/auth/customer/profile
PUT  /api/auth/customer/profile
```

**Company Authentication Endpoints**
```dart
// Company user authentication
POST /api/auth/company/login
POST /api/auth/company/refresh-token
GET  /api/auth/company/profile
PUT  /api/auth/company/profile
```

**Super Admin Authentication Endpoints**
```dart
// Super admin authentication
POST /api/auth/super-admin/login
POST /api/auth/super-admin/refresh-token
GET  /api/auth/super-admin/profile
```

**Public Endpoints (Customer App)**
```dart
// Public flight search and deals
GET  /api/deals/search
GET  /api/deals/{id}
GET  /api/aircraft/public
GET  /api/aircraft/{id}/availability
GET  /api/aircraft/{id}/calendar/{year}/{month}
GET  /api/locations
POST /api/bookings
GET  /api/bookings/user/{userId}

// Aircraft availability checking
GET  /api/availability/check
POST /api/availability/check-multiple
GET  /api/availability/aircraft/{aircraftId}/dates
GET  /api/availability/company/{companyId}/fleet

// User document management
GET  /api/users/{userId}/documents
POST /api/users/{userId}/documents
PUT  /api/users/{userId}/documents/{id}
DELETE /api/users/{userId}/documents/{id}
GET  /api/users/{userId}/documents/receipts
GET  /api/users/{userId}/documents/tickets

// User trip history
GET  /api/users/{userId}/trip-history
GET  /api/users/{userId}/trip-history/{id}
PUT  /api/users/{userId}/trip-history/{id}/rating
POST /api/users/{userId}/trip-history/{id}/photos

// User calendar
GET  /api/users/{userId}/calendar
POST /api/users/{userId}/calendar
PUT  /api/users/{userId}/calendar/{id}
DELETE /api/users/{userId}/calendar/{id}
GET  /api/users/{userId}/calendar/upcoming
GET  /api/users/{userId}/calendar/month/{year}/{month}
```

**Company Management Endpoints**
```dart
// Company aircraft management
GET  /api/company/{companyId}/aircraft
POST /api/company/{companyId}/aircraft
PUT  /api/company/{companyId}/aircraft/{id}
DELETE /api/company/{companyId}/aircraft/{id}

// Aircraft availability management
GET  /api/company/{companyId}/aircraft/{aircraftId}/availability
POST /api/company/{companyId}/aircraft/{aircraftId}/availability
PUT  /api/company/{companyId}/aircraft/{aircraftId}/availability/{id}
DELETE /api/company/{companyId}/aircraft/{aircraftId}/availability/{id}
GET  /api/company/{companyId}/aircraft/{aircraftId}/calendar
GET  /api/company/{companyId}/fleet/availability
POST /api/company/{companyId}/aircraft/{aircraftId}/block-dates
POST /api/company/{companyId}/aircraft/{aircraftId}/maintenance-schedule

// Company pilot management
GET  /api/company/{companyId}/pilots
POST /api/company/{companyId}/pilots
PUT  /api/company/{companyId}/pilots/{id}
DELETE /api/company/{companyId}/pilots/{id}
GET  /api/company/{companyId}/pilots/available
GET  /api/company/{companyId}/pilots/{id}/schedule

// Pilot assignment management
GET  /api/company/{companyId}/assignments
POST /api/company/{companyId}/assignments
PUT  /api/company/{companyId}/assignments/{id}
GET  /api/company/{companyId}/assignments/booking/{bookingId}
GET  /api/company/{companyId}/assignments/pilot/{pilotId}

// Pilot payment management
GET  /api/company/{companyId}/pilot-payments
POST /api/company/{companyId}/pilot-payments
PUT  /api/company/{companyId}/pilot-payments/{id}
GET  /api/company/{companyId}/pilot-payments/pilot/{pilotId}
GET  /api/company/{companyId}/pilot-payments/pending

// Crew management
GET  /api/company/{companyId}/crew
POST /api/company/{companyId}/crew
PUT  /api/company/{companyId}/crew/{id}
DELETE /api/company/{companyId}/crew/{id}

// Company deal management
GET  /api/company/{companyId}/deals
POST /api/company/{companyId}/deals
PUT  /api/company/{companyId}/deals/{id}
DELETE /api/company/{companyId}/deals/{id}

// Company booking management
GET  /api/company/{companyId}/bookings
GET  /api/company/{companyId}/bookings/{id}
PUT  /api/company/{companyId}/bookings/{id}

// Company rates management
GET  /api/company/{companyId}/rates
POST /api/company/{companyId}/rates
PUT  /api/company/{companyId}/rates/{id}

// Pilot calendar management
GET  /api/company/{companyId}/pilots/{pilotId}/calendar
POST /api/company/{companyId}/pilots/{pilotId}/calendar
PUT  /api/company/{companyId}/pilots/{pilotId}/calendar/{id}
DELETE /api/company/{companyId}/pilots/{pilotId}/calendar/{id}
GET  /api/company/{companyId}/pilots/calendar/overview
GET  /api/company/{companyId}/pilots/calendar/month/{year}/{month}
GET  /api/company/{companyId}/pilots/availability/{date}

// Company analytics
GET  /api/company/{companyId}/analytics
GET  /api/company/{companyId}/revenue
GET  /api/company/{companyId}/payouts
GET  /api/company/{companyId}/pilot-analytics
```

**Payment Endpoints**
```dart
// Payment processing (multi-tenant)
POST /api/payments/card
POST /api/payments/mpesa
GET  /api/payments/history/{userId}
GET  /api/payments/{transactionId}
GET  /api/company/{companyId}/payments
```

**Super Admin Endpoints**
```dart
// Platform management
GET  /api/super-admin/companies
POST /api/super-admin/companies
PUT  /api/super-admin/companies/{id}
DELETE /api/super-admin/companies/{id}

// Company user management
GET  /api/super-admin/companies/{companyId}/users
POST /api/super-admin/companies/{companyId}/users
PUT  /api/super-admin/companies/{companyId}/users/{id}

// Platform analytics
GET  /api/super-admin/analytics
GET  /api/super-admin/revenue
GET  /api/super-admin/bookings

// Payout management
GET  /api/super-admin/payouts
POST /api/super-admin/payouts/process
PUT  /api/super-admin/payouts/{id}
```

### 1.3 HTTP Client Configuration

**Features to Implement:**
- Base URL configuration
- Authentication headers
- Request/response logging
- Timeout handling
- Retry mechanisms
- Network connectivity checks

---

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

## 📊 3. Data Models Implementation

### 3.1 Flutter Data Models Structure

**File Structure:**
```
lib/core/models/
├── user_model.dart
├── user_document_model.dart
├── user_trip_history_model.dart
├── user_calendar_event_model.dart
├── company_model.dart
├── company_user_model.dart
├── super_admin_model.dart
├── pilot_model.dart
├── pilot_assignment_model.dart
├── pilot_payment_model.dart
├── pilot_calendar_event_model.dart
├── crew_member_model.dart
├── aircraft_model.dart
├── aircraft_availability_model.dart
├── deal_model.dart
├── booking_model.dart
├── passenger_model.dart
├── payment_model.dart
├── company_payout_model.dart
├── lease_model.dart
├── location_model.dart
├── rate_model.dart
├── notification_model.dart
├── cloudinary_response_model.dart
└── api_response_model.dart
```

### 3.2 Core Model Features

**Every model should include:**
- JSON serialization/deserialization
- Validation methods
- Copy/update methods
- toString() for debugging
- Equality operators

**Example Model Structure:**
```dart
class UserModel {
  final String id;
  final String? email;
  final String? phoneNumber;
  final String? firstName;
  final String? lastName;
  final String? countryCode;
  final String? profileImageUrl;
  final int loyaltyPoints;
  final double walletBalance;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Constructor, fromJson, toJson, copyWith, etc.
}
```

---

## 🏢 4. Multi-Tenant Architecture Overview

### 4.1 User Roles & Permissions

**Super Admin (Platform Level)**
- Create and manage airline companies
- Approve company registrations
- Process company payouts
- Monitor platform-wide analytics
- Manage platform settings and commission rates
- Handle disputes and customer support escalations

**Company Admin (Company Level)**
- Manage company profile and settings
- Add/remove company users
- View company analytics and revenue
- Manage payment methods and payout settings
- Handle company-level customer support

**Company Manager (Company Level)**
- Manage aircraft inventory
- Manage pilot roster and assignments
- Create and manage deals/packages
- Set pricing and rates
- View bookings and customer details
- Handle operational tasks
- Assign pilots to flights
- Manage crew schedules

**Company Operator (Company Level)**
- View assigned bookings
- Update booking status
- Communicate with customers
- Handle day-to-day operations
- Confirm pilot assignments
- Update flight status and reports

**Company Finance (Company Level)**
- View financial reports
- Manage payment settings
- Track revenue and payouts
- Handle billing and invoicing
- Process pilot payments
- Manage payroll and crew compensation
- Track pilot working hours and overtime

**Customer (Platform Level)**
- Browse and book flights
- Manage personal profile
- View booking history
- Make payments and receive refunds

### 4.2 Data Isolation Strategy

**Company-Specific Data:**
- Aircraft belong to specific companies
- Pilots and crew are employed by companies
- Pilot assignments and schedules per company
- Pilot payments and payroll per company
- Deals are created by companies
- Bookings are processed by companies
- Payments are split between platform and companies
- Rates are set per company

**Shared Data:**
- Locations (airports) are shared across platform
- Customers can book with any company
- Platform settings affect all companies

### 4.3 Revenue Sharing Model

**Payment Flow:**
1. Customer pays total amount to platform
2. Platform deducts commission (configurable %)
3. Remaining amount goes to company earnings
4. Companies receive payouts on scheduled basis

**Commission Structure:**
- Basic Plan: 8% commission
- Premium Plan: 5% commission  
- Enterprise Plan: 3% commission

---

## 📸 5. Cloudinary Service Implementation

### 5.1 Flutter Cloudinary Integration

**File Structure:**
```
lib/core/services/
├── cloudinary_service.dart      # Main Cloudinary service
├── image_upload_service.dart    # Image upload handling
├── image_cache_service.dart     # Local image caching
└── image_transform_service.dart # Image transformation utils
```

### 5.2 Cloudinary Service Features

**Core Upload Methods:**
```dart
class CloudinaryService {
  // Profile image upload
  Future<CloudinaryResponse> uploadProfileImage(File imageFile, String userId);
  
  // Aircraft gallery upload
  Future<List<CloudinaryResponse>> uploadAircraftImages(List<File> images, int aircraftId);
  
  // Document upload (leases, signatures)
  Future<CloudinaryResponse> uploadDocument(File document, String type, String entityId);
  
  // Delete image by public ID
  Future<bool> deleteImage(String publicId);
  
  // Generate optimized URLs
  String getOptimizedUrl(String publicId, ImageTransformation transformation);
}
```

**Image Transformation Utils:**
```dart
class ImageTransformation {
  final int? width;
  final int? height;
  final String? crop;
  final String? quality;
  final String? format;
  
  // Predefined transformations
  static const profileThumb = ImageTransformation(width: 150, height: 150, crop: 'fill');
  static const aircraftLarge = ImageTransformation(width: 1200, height: 800, crop: 'fill');
}
```

### 5.3 Flutter Dependencies

**pubspec.yaml additions:**
```yaml
dependencies:
  cloudinary_public: ^0.21.0    # Cloudinary upload
  image_picker: ^1.0.4          # Image selection
  image_cropper: ^5.0.1         # Image cropping
  cached_network_image: ^3.3.1  # Already included
  file_picker: ^6.1.1           # Document file selection
  path_provider: ^2.1.1         # Local file storage paths
  table_calendar: ^3.0.9        # Calendar widget
  syncfusion_flutter_calendar: ^23.1.36  # Advanced calendar features
  calendar_date_picker2: ^0.5.3 # Enhanced date picker with blocking
  flutter_calendar_carousel: ^2.4.2 # Customizable calendar with availability
  pdf: ^3.10.4                  # PDF generation for receipts
  printing: ^5.11.0             # PDF printing and sharing
  share_plus: ^7.2.1            # Document sharing
  url_launcher: ^6.2.1          # Open documents externally
```

---

## 📅 6. Document & Calendar Management

### 6.1 User Document Management

**File Structure:**
```
lib/core/services/
├── document_service.dart         # Document upload and management
├── receipt_generator_service.dart # PDF receipt generation
├── calendar_service.dart         # Calendar operations
└── file_manager_service.dart     # Local file operations
```

**Document Management Features:**
```dart
class DocumentService {
  // Upload user documents
  Future<UserDocument> uploadDocument(File file, String userId, DocumentType type);
  
  // Generate receipt PDF
  Future<String> generateReceiptPDF(BookingModel booking);
  
  // Generate e-ticket
  Future<String> generateETicket(BookingModel booking);
  
  // Get user documents by type
  Future<List<UserDocument>> getUserDocuments(String userId, DocumentType? type);
  
  // Share document
  Future<void> shareDocument(String documentUrl, String fileName);
  
  // Download document locally
  Future<String> downloadDocument(String documentUrl, String fileName);
}
```

### 6.2 Calendar Integration

**Calendar Features:**
```dart
class CalendarService {
  // User calendar management
  Future<List<CalendarEvent>> getUserEvents(String userId, DateTime month);
  Future<CalendarEvent> createUserEvent(String userId, CalendarEvent event);
  Future<void> updateUserEvent(String eventId, CalendarEvent event);
  Future<void> deleteUserEvent(String eventId);
  
  // Pilot calendar management
  Future<List<PilotCalendarEvent>> getPilotSchedule(String pilotId, DateTime month);
  Future<PilotCalendarEvent> createPilotEvent(String pilotId, PilotCalendarEvent event);
  Future<bool> checkPilotAvailability(String pilotId, DateTime startTime, DateTime endTime);
  
  // Aircraft availability management
  Future<List<AircraftAvailability>> getAircraftAvailability(int aircraftId, DateTime month);
  Future<bool> checkAircraftAvailability(int aircraftId, DateTime startTime, DateTime endTime);
  Future<List<DateTime>> getBlockedDates(int aircraftId, DateTime startDate, DateTime endDate);
  Future<AircraftAvailability> blockAircraftDates(int aircraftId, DateTime start, DateTime end, String reason);
  Future<void> createMaintenanceSchedule(int aircraftId, DateTime start, DateTime end, String notes);
  
  // Booking conflict checking
  Future<bool> hasBookingConflict(int aircraftId, DateTime startTime, DateTime endTime);
  Future<List<ConflictInfo>> checkMultipleAircraftAvailability(List<int> aircraftIds, DateTime start, DateTime end);
  Future<Map<DateTime, bool>> getAvailabilityCalendar(int aircraftId, DateTime month);
  
  // Automatic event creation
  Future<void> createBookingEvents(BookingModel booking);
  Future<void> createPilotAssignmentEvent(PilotAssignment assignment);
  Future<void> createAircraftBookingBlock(BookingModel booking);
  
  // Reminder notifications
  Future<void> scheduleEventReminders(CalendarEvent event);
}
```

### 6.3 Trip History Management

**Trip History Features:**
- Automatic trip record creation on booking completion
- User rating and review system
- Trip photo uploads and gallery
- Receipt and ticket document linking
- Trip statistics and analytics
- Export trip history to PDF

### 6.4 Aircraft Availability & Booking Conflicts

**Availability Tracking Features:**
```dart
class AircraftAvailabilityService {
  // Real-time availability checking
  Future<bool> isAircraftAvailable(int aircraftId, DateTime start, DateTime end);
  
  // Calendar view for booking
  Future<Map<String, dynamic>> getBookingCalendar(int aircraftId, int year, int month);
  
  // Conflict detection
  Future<List<BookingConflict>> detectConflicts(int aircraftId, DateTime start, DateTime end);
  
  // Block management
  Future<void> blockDatesForMaintenance(int aircraftId, DateTime start, DateTime end, String reason);
  Future<void> removeAvailabilityBlock(String blockId);
  
  // Automatic booking blocks
  Future<void> createBookingBlock(BookingModel booking);
  Future<void> updateBookingBlock(BookingModel booking);
  Future<void> removeBookingBlock(String bookingId);
}
```

**Calendar Integration for Booking:**
- **Blocked Dates** - Grayed out unavailable dates
- **Booked Dates** - Show existing bookings (anonymized)
- **Maintenance Periods** - Display maintenance schedules
- **Available Dates** - Highlight selectable dates
- **Partial Availability** - Show partially booked days
- **Real-time Updates** - Live availability checking

**Conflict Prevention:**
- Check availability before booking confirmation
- Prevent double-booking of aircraft
- Account for repositioning time between flights
- Consider maintenance schedules
- Handle timezone differences for international flights

### 6.5 Document Types & Auto-Generation

**Auto-Generated Documents:**
- **Booking Confirmation** - Created on successful booking
- **E-Ticket** - Generated with QR code for boarding
- **Receipt/Invoice** - Created after payment completion
- **Itinerary** - Detailed trip information with timeline
- **Boarding Pass** - Generated 24 hours before departure

**User-Uploaded Documents:**
- Travel insurance documents
- Passport/ID copies
- Medical certificates
- Custom travel documents

---

## 🔐 7. Firebase Authentication Integration

### 7.1 Firebase Services Setup

**File Structure:**
```
lib/core/auth/
├── firebase_auth_service.dart    # Firebase authentication wrapper
├── auth_repository.dart          # Authentication repository
├── auth_exceptions.dart          # Custom auth exceptions
└── auth_state_notifier.dart      # Authentication state management
```

### 7.2 Authentication Features

**Core Authentication Methods:**
- Phone number authentication with OTP
- Email/password authentication
- Token refresh management
- User session persistence
- Logout and account deletion

**Firebase Security Rules:**
```javascript
// Firestore security rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## ⚠️ 8. Error Handling & Loading States

### 8.1 Error Handling Architecture

**File Structure:**
```
lib/core/error/
├── app_exceptions.dart           # Custom exception classes
├── error_handler.dart            # Global error handler
├── failure_model.dart            # Failure response model
└── error_messages.dart           # User-friendly error messages
```

### 8.2 Exception Types

**Custom Exception Classes:**
```dart
// Network exceptions
class NetworkException extends AppException
class TimeoutException extends AppException
class ServerException extends AppException

// Authentication exceptions
class AuthException extends AppException
class TokenExpiredException extends AppException

// Business logic exceptions
class BookingException extends AppException
class PaymentException extends AppException
```

### 8.3 Loading States Implementation

**Loading State Management:**
```dart
enum LoadingState {
  initial,
  loading,
  success,
  error,
}

class ApiState<T> {
  final LoadingState state;
  final T? data;
  final String? error;
  final bool isLoading;
}
```

---

## 🔧 9. Implementation Priority Order

### Week 1: Foundation Setup
1. **Day 1-2:** Core API service architecture
2. **Day 3-4:** Data models implementation
3. **Day 5-7:** Basic HTTP client setup

### Week 2: API Integration
1. **Day 8-9:** Authentication endpoints
2. **Day 10-11:** Booking endpoints
3. **Day 12-14:** Aircraft and payment endpoints

### Week 3: Database Setup
1. **Day 15-16:** MySQL schema creation
2. **Day 17-18:** Database connection setup
3. **Day 19-21:** Data persistence testing

### Week 4: Firebase Integration
1. **Day 22-23:** Firebase auth service
2. **Day 24-25:** User session management
3. **Day 26-28:** Authentication flow integration

### Week 5: Error Handling
1. **Day 29-30:** Exception handling framework
2. **Day 31-32:** Loading states implementation
3. **Day 33-35:** Error message system

### Week 6: Testing & Optimization
1. **Day 36-37:** API testing and validation
2. **Day 38-39:** Performance optimization
3. **Day 40-42:** Documentation and cleanup

---

## 📋 Deliverables Checklist

### Code Deliverables
- [ ] Complete API service layer
- [ ] All data models with proper serialization
- [ ] MySQL database schema with sample data
- [ ] Firebase authentication integration
- [ ] Error handling framework
- [ ] Loading states implementation

### Documentation Deliverables
- [ ] API documentation with examples
- [ ] Database schema documentation
- [ ] Authentication flow documentation
- [ ] Error handling guide
- [ ] Testing procedures

### Testing Deliverables
- [ ] Unit tests for all models
- [ ] Integration tests for API services
- [ ] Authentication flow testing
- [ ] Error scenario testing
- [ ] Performance benchmarks

---

## 🚀 Next Phase Preparation

After completing Phase 1, the foundation will be ready for:
- **Phase 2:** Complete customer features implementation
- **Phase 3:** Admin platform development
- **Phase 4:** Leasing system integration

This backend foundation will provide the robust architecture needed to support all planned features while maintaining scalability and performance.

---

## 📞 Support & Resources

- **Database Design Tools:** MySQL Workbench, phpMyAdmin
- **API Testing:** Postman, Insomnia
- **Firebase Console:** Authentication and project management
- **Monitoring:** Firebase Analytics, Crashlytics
- **Documentation:** Swagger/OpenAPI for API docs 