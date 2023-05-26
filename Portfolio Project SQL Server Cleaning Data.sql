/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM Project1.dbo.[Nashville Housing]

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM Project1.dbo.[Nashville Housing]

UPDATE [Nashville Housing]
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE [Nashville Housing]
ADD SaleDateConverted Date;

UPDATE [Nashville Housing]
SET SaleDateConverted = CONVERT(Date,SaleDate)



-- If it doesn't Update properly




 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT PropertyAddress
FROM Project1.dbo.[Nashville Housing]
WHERE PropertyAddress IS NULL

SELECT *
FROM Project1.dbo.[Nashville Housing]
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Project1.dbo.[Nashville Housing] AS a
JOIN Project1.dbo.[Nashville Housing] AS b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Project1.dbo.[Nashville Housing] AS a
JOIN Project1.dbo.[Nashville Housing] AS b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null







--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM Project1.dbo.[Nashville Housing]
--WHERE PropertyAddress IS NULL

SELECT 
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM Project1.dbo.[Nashville Housing]

ALTER TABLE [Nashville Housing]
ADD PropertySplitAddress nvarchar(255);

UPDATE [Nashville Housing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE [Nashville Housing]
ADD PropertySplitCity nvarchar(255);

UPDATE [Nashville Housing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM Project1.dbo.[Nashville Housing]

SELECT OwnerAddress
FROM Project1.dbo.[Nashville Housing]

SELECT 
PARSENAME (REPLACE(OwnerAddress,',','.'),3),
PARSENAME (REPLACE(OwnerAddress,',','.'),2),
PARSENAME (REPLACE(OwnerAddress,',','.'),1)
FROM Project1.dbo.[Nashville Housing]

ALTER TABLE [Nashville Housing]
ADD OwnerSplitAddress nvarchar(255);

UPDATE [Nashville Housing]
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE [Nashville Housing]
ADD OwnerSplitCity nvarchar(255);

UPDATE [Nashville Housing]
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE [Nashville Housing]
ADD OwnerSplitState nvarchar(255);

UPDATE [Nashville Housing]
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress,',','.'),1)
--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT (SoldAsVacant)
FROM Project1.dbo.[Nashville Housing]

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM Project1.dbo.[Nashville Housing]
GROUP BY (SoldAsVacant)
ORDER BY (SoldAsVacant)

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant 
	 END
FROM Project1.dbo.[Nashville Housing]


UPDATE [Nashville Housing]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant 
	 END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM Project1.dbo.[Nashville Housing]
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

--Verificando

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM Project1.dbo.[Nashville Housing]
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1



--order by ParcelID



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
SELECT *
FROM Project1.dbo.[Nashville Housing]

ALTER TABLE Project1.dbo.[Nashville Housing]
DROP COLUMN PropertyAddress, TaxDistrict, OwnerAddress

ALTER TABLE Project1.dbo.[Nashville Housing]
DROP COLUMN SaleDate