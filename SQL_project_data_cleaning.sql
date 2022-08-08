				/**** DATA CLEANING IN SQL ****/
------------------------------------------------------------------------------------------------------------------------
SELECT *
FROM MyPortfolio.DBO.NashvilleTNHousing
------------------------------------------------------------------------------------------------------------------------
/** Standardize Date Format **/

SELECT SaleDate
FROM MyPortfolio.DBO.NashvilleTNHousing  -- Problem in Column

SELECT SalesDate, CONVERT(date,SaleDate)
FROM MyPortfolio.dbo.NashvilleTNHousing

UPDATE NashvilleTNHousing
SET SaleDate = CONVERT(date,SaleDate) 

ALTER TABLE NashvilleTNHousing
ADD SalesDate Date;

UPDATE NashvilleTNHousing
SET SalesDate = CONVERT(Date,SaleDate)  -- Cleaning Track, Success.

--------------------------------------------------------------------------------------------------------------------------
--Populate Property Address Data																			-- Problem in Column

SELECT *
FROM MyPortfolio.DBO.NashvilleTNHousing
WHERE PropertyAddress IS NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM MyPortfolio.DBO.NashvilleTNHousing a
JOIN MyPortfolio.DBO.NashvilleTNHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM MyPortfolio.DBO.NashvilleTNHousing a
JOIN MyPortfolio.DBO.NashvilleTNHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL																				-- Cleaning Track, Success.


---------------------------------------------------------------------------------------------------------------------------
--Breaking Out Address into Individual Columns (Add, City, State) PropertyAddress Column

SELECT PropertyAddress
FROM MyPortfolio.DBO.NashvilleTNHousing																			  --Problem

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) AS City
FROM MyPortfolio.DBO.NashvilleTNHousing

ALTER TABLE NashvilleTNHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleTNHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleTNHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleTNHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

SELECT *
FROM MyPortfolio.DBO.NashvilleTNHousing																			--Cleaning Track, Success

------------------------------------------------------------------------------------------------------------------------------------------------
--OwnersAddress Column

SELECT OwnerAddress
FROM MyPortfolio.DBO.NashvilleTNHousing																				--Problem

SELECT 
  PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
  ,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
  ,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
  FROM MyPortfolio.DBO.NashvilleTNHousing

ALTER TABLE NashvilleTNHousing
ADD OwnerSplitAddress Nvarchar(255);
UPDATE NashvilleTNHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleTNHousing
ADD OwnerSplitCity Nvarchar(255);
UPDATE NashvilleTNHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleTNHousing
ADD OwnerSplitState Nvarchar(255);
UPDATE NashvilleTNHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT *
FROM MyPortfolio.DBO.NashvilleTNHousing																				--Cleaning Track, Success
----------------------------------------------------------------------------------------------------------------------------------------------------

-- Changing Y and N to Yes and No in "SoldAsVacant" Field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM MyPortfolio.DBO.NashvilleTNHousing
GROUP BY SoldAsVacant
ORDER BY 2																											-- Problem

SELECT 
	CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		 WHEN SoldAsVacant = 'N' THEN 'NO'
		 ELSE SoldAsVacant
		 END
FROM MyPortfolio.DBO.NashvilleTNHousing

UPDATE NashvilleTNHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		 WHEN SoldAsVacant = 'N' THEN 'NO'
		 ELSE SoldAsVacant
		 END																										--Cleaning Track, Success

-----------------------------------------------------------------------------------------------------------------------------------------------------

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
FROM MyPortfolio.DBO.NashvilleTNHousing

)															
SELECT *                            
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

/*** I used the following command to delete the duplicate rows
DELETE                          
FROM RowNumCTE
WHERE row_num > 1
***/
----------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete unused Columns
SELECT *
FROM MyPortfolio.DBO.NashvilleTNHousing

ALTER TABLE MyPortfolio.DBO.NashvilleTNHousing
DROP COLUMN SaleDate, OwnerAddress, TaxDistrict, PropertyAddress

