pragma solidity ^0.4.18;

library BookingLibrary {

  struct Day {
    address owner;
    uint8[] hoursBooked;
    mapping(uint8 => address) hour;
  }

  struct Month {
    address owner;
    uint8[] daysBooked;
    mapping(uint8 => Day) day;
  }

  struct Bookings {
    mapping(uint32 => mapping(uint8 => Month)) year;
  }

  function checkAvailablity(Bookings storage self, uint32 _year, uint numYears) returns (bool);
  function checkAvailablity(Bookings storage self, uint32 _year, uint8 startingMonth, uint numMonths) returns (bool);
  function checkAvailablity(Bookings storage self, uint32 _year, uint8 month, uint8 startingDay, uint numDays) returns (bool);
  function checkAvailablity(Bookings storage self, uint32 _year, uint8 month, uint8 _day, uint8 startingHour, uint8 numHours) returns (bool) {
    //Check if month is available
    if(self.year[_year][month].owner == address(0)) return false;
    //Check if day is available
    if(self.year[_year][month].day[_day].owner == address(0)) return false;
    //Check if hours are available
    uint8 toHour = startingHour + numHours;
    for (uint8 i = startingHour; i < toHour ; i++) {
      if(self.year[_year][month].day[_day].hour[i] != address(0)) {
        return false;
      }
    }

    return true;
  }

}
