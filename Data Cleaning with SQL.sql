-- DATA CLEANING IN SQL
SELECT TOP 100 *
FROM nashville;

-- STANDARDIZE THE SALEDATE COLUMN; REMOVE THE TIME
UPDATE nashville
SET SaleDate = CONVERT(Date,SaleDate);

/*
SELECT SaleDate, CAST(SaleDate AS date)
FROM nashville;

UPDATE nashville
SET SaleDate = CAST(SaleDate AS date);
*/

ALTER TABLE nashville
ADD SaleDatee Date;

UPDATE nashville
SET SaleDatee = CONVERT(Date,SaleDate);

ALTER TABLE nashville
DROP COLUMN SaleDate;

-- POPULATE THE PROPERTY ADDRESS COLUMN - REPLACE NULLS
SELECT * FROM nashville;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashville a
JOIN nashville b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashville a
JOIN nashville b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL;

-- BREAK OUT THE PROPERTY ADDRESS COLUMN INTO INDIVIDUAL COLUMNS (ADDRESS, CITY)
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS PropertyAdd,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS PropertyCity
FROM nashville;


ALTER TABLE nashville
ADD PropertyAdd NVARCHAR(255);

UPDATE nashville
SET PropertyAdd = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE nashville
ADD PropertyCity NVARCHAR(255);

UPDATE nashville
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

/*
ALTER TABLE nashville
DROP COLUMN PropertyAddress
*/

-- BREAK OUT THE OWNER ADDRESS COLUMN INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)
SELECT
SUBSTRING(OwnerAddress, 1, CHARINDEX(',', OwnerAddress) -1) AS OwnerAdd,
SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) +1, LEN(OwnerAddress)) AS OwnerCityState
FROM nashville;

ALTER TABLE nashville
ADD OwnerAdd NVARCHAR(255);

UPDATE nashville
SET OwnerAdd = SUBSTRING(OwnerAddress, 1, CHARINDEX(',', OwnerAddress) -1);

ALTER TABLE nashville
ADD OwnerCityState NVARCHAR(255);

UPDATE nashville
SET OwnerCityState = SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) +1, LEN(OwnerAddress));

SELECT
SUBSTRING(OwnerCityState, 1, CHARINDEX(',', OwnerCityState) -1) AS OwnerAddCity,
SUBSTRING(OwnerCityState, CHARINDEX(',', OwnerCityState) +1, LEN(OwnerCityState)) AS OwnerAddState
FROM nashville;

ALTER TABLE nashville
ADD OwnerAddCity NVARCHAR(255);

UPDATE nashville
SET OwnerAddCity = SUBSTRING(OwnerCityState, 1, CHARINDEX(',', OwnerCityState) -1);

ALTER TABLE nashville
ADD OwnerAddState NVARCHAR(255);

UPDATE nashville
SET OwnerAddState = SUBSTRING(OwnerCityState, CHARINDEX(',', OwnerCityState) +1, LEN(OwnerCityState));

ALTER TABLE nashville
DROP COLUMN OwnerCityState;

/*
SELECT 
PARSENAME(REPLACE(Owneraddress, ',','.'), 3),
PARSENAME(REPLACE(Owneraddress, ',','.'), 2),
PARSENAME(REPLACE(Owneraddress, ',','.'), 1)
FROM nashville;

ALTER TABLE nashville
ADD OwnerAdd NVARCHAR(255);

ALTER TABLE nashville
ADD OwnerAddCity NVARCHAR(255);

ALTER TABLE nashville
ADD OwnerAddState NVARCHAR(255);

UPDATE nashville
SET OwnerAdd = PARSENAME(REPLACE(Owneraddress, ',','.'), 3);

UPDATE nashville
SET OwnerAddCity = PARSENAME(REPLACE(Owneraddress, ',','.'), 2);

ALTER TABLE nashville
ADD OwnerAddState NVARCHAR(255);

UPDATE nashville
SET OwnerAddState = PARSENAME(REPLACE(Owneraddress, ',','.'), 1);
*/

-- CHANGING 'Y TO YES' AND 'N TO NO' IN THE SOLDASVACANT COLUMN
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM nashville;

UPDATE nashville
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END;

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM nashville
GROUP BY SoldAsVacant
ORDER BY 2;

-- REMOVE DUPLICATES
WITH Duplicates AS (
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDatee,
			 LegalReference
			 ORDER BY UniqueID) AS Row_Num
FROM nashville)
DELETE
FROM Duplicates
WHERE Row_Num > 1;

-- DELETE UNUSED COLUMNS
ALTER TABLE nashville
DROP COLUMN PropertyAddress, TaxDistrict, OwnerAddress;

SELECT * FROM nashville;