pragma solidity ^0.4.11;

import "../PrivateCall.sol";

/*
 * UnitType
 * A type of unit that a Hotel has in his inventory, with all the units
 * information and avaliability.
 */
contract UnitType is PrivateCall {

	bool public active;
	bytes32 public unitType;
	uint public totalUnits;

	// The units that the hotels has of this type.
	mapping(uint => Unit) public units;

	struct Unit {
		//Unit Information
		string name;
		string description;
		uint minGuests;
		uint maxGuests;
		string price;
		bool active;
		uint[] amenities;
    mapping(uint => uint) amenitiesIndex;
		// An array of all days avaliability after 01-01-1970
		mapping(uint => UnitDay) reservations;
    string[] images;
  }

	struct UnitDay {
		string specialPrice;
		address bookedBy;
	}

	event Book(address from, uint unitIndex, uint fromDay, uint daysAmount);

  // Constructor

	function UnitType(address _owner, bytes32 _unitType){
		owner = _owner;
		unitType = _unitType;
	}

	// Owner methods

	function addUnit(
    string name,
    string description,
    uint minGuests,
    uint maxGuests,
    string price
  ) onlyOwner() {
		uint[] memory empty = new uint[](0);
    string[] memory emptyImgs = new string[](0);
    totalUnits ++;
		units[totalUnits] = Unit(
      name,
      description,
      minGuests,
      maxGuests,
      price,
      true,
      empty,
      emptyImgs
    );
		units[totalUnits].amenities.length ++;
	}

	function editUnit(
    uint unitIndex,
    string name,
    string description,
    uint minGuests,
    uint maxGuests,
    string price
  ) onlyOwner() {
		if ((unitIndex > totalUnits) || (unitIndex == 0))
			throw;
		units[unitIndex].name = name;
		units[unitIndex].description = description;
		units[unitIndex].minGuests = minGuests;
		units[unitIndex].maxGuests = maxGuests;
    units[unitIndex].price = price;
	}

	function active(bool _active) onlyOwner() {
		active = _active;
	}

	function unitActive(uint unitIndex, bool _active) onlyOwner() {
		if ((unitIndex > totalUnits) || (unitIndex == 0))
			throw;
		units[unitIndex].active = _active;
	}

	function setPrice(
    string price,
    uint unitIndex,
    uint fromDay,
    uint daysAmount
  ) onlyOwner() {
		if ((unitIndex > totalUnits) || (unitIndex == 0))
			throw;
		uint toDay = fromDay+daysAmount;
		for (uint i = fromDay; i <= toDay; i++)
			units[unitIndex].reservations[i].specialPrice = price;
	}

  function addImage(uint unitIndex, string url) onlyOwner() {
    if ((unitIndex > totalUnits) || (unitIndex == 0))
			throw;
		units[unitIndex].images.push(url);
	}

  function removeImage(uint unitIndex, uint imageIndex) onlyOwner() {
    if ((unitIndex > totalUnits) || (unitIndex == 0))
			throw;
		delete units[unitIndex].images[imageIndex];
	}

	function addAmenity(uint unitIndex, uint amenity) onlyOwner() {
		if ((unitIndex > totalUnits) || (unitIndex == 0))
			throw;
    units[unitIndex].amenitiesIndex[amenity] = units[unitIndex].amenities.length;
		units[unitIndex].amenities.push(amenity);
	}

	function removeAmenity(uint unitIndex, uint amenity) onlyOwner() {
		if ((unitIndex > totalUnits) || (unitIndex == 0))
			throw;
		delete units[unitIndex].amenities[ units[unitIndex].amenitiesIndex[amenity] ];
    units[unitIndex].amenitiesIndex[amenity] = 0;
	}

	function removeUnit(uint unitIndex) onlyOwner() {
		if ((unitIndex > totalUnits) || (unitIndex == 0))
			throw;
		delete units[unitIndex];
    totalUnits --;
	}

	// Methods from private call

	function book(
    address from,
    uint unitIndex,
    uint fromDay,
    uint daysAmount,
    bytes finalDataCall
  ) fromSelf() {
		if (!units[unitIndex].active)
			throw;
		bool canBook = true;
		uint toDay = fromDay+daysAmount;

		for (uint i = fromDay; i <= toDay ; i++){
			if (units[unitIndex].reservations[i].bookedBy != address(0)) {
				canBook = false;
				break;
			}
		}

		if (canBook){
			for (i = fromDay; i <= toDay ; i++)
				units[unitIndex].reservations[i].bookedBy = from;
			Book(from, unitIndex, fromDay, toDay);
      owner.call(finalDataCall);
		}
	}

	// Public methods

  function getUnit(uint unitIndex) constant returns(
    string, string, uint, uint, string, bool
  ) {
		return (
      units[unitIndex].name,
  		units[unitIndex].description,
  		units[unitIndex].minGuests,
  		units[unitIndex].maxGuests,
  		units[unitIndex].price,
  		units[unitIndex].active
    );
	}

  function getAmenities(uint unitIndex) constant returns(uint[]) {
		return (units[unitIndex].amenities);
	}

	function getReservation(
    uint unitIndex,
    uint day
  ) constant returns(string, address) {
		return (
      units[unitIndex].reservations[day].specialPrice,
      units[unitIndex].reservations[day].bookedBy
    );
	}

  function getImage(uint unitIndex, uint i) constant returns (string) {
		return units[unitIndex].images[i];
	}

  function getImagesLength(uint unitIndex) constant returns (uint) {
		return units[unitIndex].images.length;
	}

}