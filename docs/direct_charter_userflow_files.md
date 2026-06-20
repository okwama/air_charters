## Direct Charter Booking Userflow — Files Map

This document lists the Dart files involved in the Direct Charter booking userflow, grouped by responsibility, with brief descriptions. Paths are relative to the `air_charters/lib` root unless otherwise noted.

### Flow from Dashboard (Direct → Select Aircraft Type → Configure)
- `features/dashboard/dashboard_screen.dart`
  - Entry point: Services grid → on tap of "Direct Charter" calls `_navigateToDirectCharter()`
  - Navigation target: `features/direct_charter/aircraft_type_selection_screen.dart`
- `features/direct_charter/aircraft_type_selection_screen.dart`
  - Shows available aircraft types; tap navigates to `AircraftResultsScreen`
- `features/direct_charter/aircraft_results_screen.dart`
  - Lists aircraft for the chosen type; selecting one navigates to `flight_configuration_screen.dart`
- `features/direct_charter/flight_configuration_screen.dart`
  - Configure times, trip type, stops, special requirements; creates inquiry via `DirectCharterService.createInquiry`
- `features/direct_charter/direct_charter_inquiry_confirmation.dart`
  - Displays inquiry confirmation; next steps proceed to pricing/payment when available

### Entry and Navigation
- `core/routes/app_pages.dart`: Declares routes for Direct Charter, including `directCharter`, `directCharterSearch`, `directCharterResults`, and `directCharterBooking`.
- `core/routes/app_routes.dart`: Route name constants referenced by `app_pages.dart`.

### Direct Charter Screens (Primary Flow)
- `features/direct_charter/flight_configuration_screen.dart`: Configures flight details (times, roundtrip, intermediate stops, special requirements); creates an inquiry via `DirectCharterService.createInquiry`.
- `features/direct_charter/direct_charter_inquiry_confirmation.dart`: Post-inquiry confirmation screen for Direct Charter (shown when inquiry is created instead of immediate payment).

### Shared Booking/Payment Screens (used when booking proceeds to payment/confirmation)
- `features/booking/booking_confirmation_page.dart`: Generic booking confirmation page used across flows with `bookingData`.
- `features/booking/payment/payment_screen.dart`: In-app checkout screen handling payment (intent-based), when applicable.

### Supporting Planning Screens
- `features/plan/stops_selection_screen.dart`: UI for adding intermediate stops to the itinerary; returns structured stops back to the calling screen.

### Models
- `core/models/direct_charter_model.dart`: Model(s) for Direct Charter aircraft and booking payloads.
- `core/models/location_model.dart`: Location entity used for origin/destination selections with lat/long support.
- `core/models/booking_stop_model.dart`: Stop model for multi-leg itineraries in Direct Charter.
- `core/models/booking_model.dart`: Generic booking entities used in confirmations and payment steps.

### Services
- `core/services/direct_charter_service.dart`: Network API for Direct Charter; includes `createInquiry` (inquiry-first flow) and booking endpoints.
- `core/services/booking_inquiry_service.dart`: Shared inquiry-related service utilities (if leveraged alongside Direct Charter inquiries).
- `core/services/booking_business_service.dart`: Booking + payment-intent orchestration used by generic booking flow (may be used when Direct Charter proceeds to payment).
- `core/services/booking_service.dart`: Lower-level booking calls used across flows.
- `core/services/aircraft_availability_service.dart`: Availability checks that can influence Direct Charter search/results.

### Shared Widgets and Utilities
- `shared/widgets/enhanced_location_picker.dart`: Location picker used in search/config screens.
- `shared/widgets/aircraft_slot_conflict_modal.dart`: Modal to show slot conflicts during booking.
- `shared/widgets/loading_widget.dart`: Progress indicator shown during network operations.
- `shared/widgets/passenger_form.dart`: Passenger form used in broader booking contexts.
- `shared/utils/app_utils.dart`: Formatting and helper utilities used in the booking/configuration screens.
- `core/error/network_error_handler.dart`: Standardized network error parsing and presentation.

### Backend (reference only, outside Flutter app)
- `air_services/apps/direct-charter-service/src/modules/direct-charter/direct-charter.service.ts`: Microservice handling Direct Charter operations.
- `air_services/apps/api-gateway/src/controllers/direct-charter.controller.ts`: Gateway controller exposing Direct Charter endpoints.
- `inactive_air_backend/src/modules/direct-charter/*`: Legacy service, schemas, and DTOs for historical reference.

### Canonical Direct Charter Userflow (via Dashboard)
1. Dashboard → Direct Charter → `aircraft_type_selection_screen.dart`
2. `aircraft_results_screen.dart` → select aircraft
3. `flight_configuration_screen.dart` → configure details and create inquiry
4. `direct_charter_inquiry_confirmation.dart` → await admin pricing
5. Payment (when priced) → Success (Trips)


