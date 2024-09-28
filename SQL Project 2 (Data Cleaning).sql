/*

SQL Data Cleaning Project

*/


SELECT *
FROM [Portfolio Project]..NashvilleHousing


--Standardize Date Format

SELECT SaleDateConverted, CONVERT (Date, SaleDate)
FROM [Portfolio Project]..NashvilleHousing

UPDATE [Portfolio Project]..NashvilleHousing
SET SaleDate = CONVERT (date, SaleDate)

--If it doesn't update properly

ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD SaleDateConverted Date

UPDATE [Portfolio Project]..NashvilleHousing
SET SaleDateConverted = CONVERT (date, SaleDate)

--Populate Property Address Data

SELECT *
FROM [Portfolio Project]..NashvilleHousing
WHERE PropertyAddress is null
ORDER By ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project]..NashvilleHousing a
JOIN [Portfolio Project]..NashvilleHousing b ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project]..NashvilleHousing a
JOIN [Portfolio Project]..NashvilleHousing b ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--Breaking out address into individual columns (Address, City, State)
--Separating the "PropertyAddress" column

SELECT PropertyAddress
FROM [Portfolio Project]..NashvilleHousing

SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM [Portfolio Project]..NashvilleHousing

ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

UPDATE [Portfolio Project]..NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD ProperySplitCity Nvarchar(255)

UPDATE [Portfolio Project]..NashvilleHousing
SET ProperySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


--Separating the "OwnerAddress" Column

SELECT OwnerAddress
FROM [Portfolio Project]..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM [Portfolio Project]..NashvilleHousing

ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE [Portfolio Project]..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD  OwnerSplitCity Nvarchar(255)

UPDATE [Portfolio Project]..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE [Portfolio Project]..NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE [Portfolio Project]..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


--Changing Y and N to Yes and No in the "SoldAsVacant" field

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio Project]..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No' ELSE SoldAsVacant
		 END
FROM [Portfolio Project]..NashvilleHousing

UPDATE [Portfolio Project]..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No' ELSE SoldAsVacant
		 END

--Removing Duplicates

WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID) row_num
FROM [Portfolio Project]..NashvilleHousing
)

DELETE
FROM RowNumCTE
WHERE row_num > 1

--Deleting Unused Columns

SELECT *
FROM [Portfolio Project]..NashvilleHousing

DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
ALTER TABLE [Portfolio Project]..NashvilleHousing

--Remove the SaleDate Column too
ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP COLUMN SaleDate















