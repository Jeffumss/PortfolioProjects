Select * 
From nashvillehousing;


-- Populating Property Address data

	-- observing that same ParcelID = same PropertyAddress for nulls
Select *
From nashvillehousing
Where PropertyAddress is null
Order by ParcelID;

	-- counting number of null property addresses
Select COUNT(*)
From nashvillehousing
Where PropertyAddress is null;

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ifnull(a.PropertyAddress, b.PropertyAddress)
From JeffumsPortfolio.nashvillehousing a
Join JeffumsPortfolio.nashvillehousing b
	on a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null;

	-- updating the PropertyAddress nulls to address with same ParcellID
UPDATE
JeffumsPortfolio.nashvillehousing a
Join JeffumsPortfolio.nashvillehousing b
	on a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
Set a.PropertyAddress = ifnull(a.PropertyAddress, b.PropertyAddress)
Where a.PropertyAddress is null;


-- Breaking out Address into Indivual Columns (Address, City, State)

Select PropertyAddress
From nashvillehousing;

Select
SUBSTRING(PropertyAddress, 1, LOCATE(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress)+1, length(PropertyAddress)) as City
From nashvillehousing;

	-- adding a new column for the address
ALTER Table nashvillehousing
Add PropertySplitAddress nvarchar(255);
	-- updating the chart for new column
UPDATE nashvillehousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',',PropertyAddress)-1);

ALTER Table nashvillehousing
Add PropertySplitCity nvarchar(255);

UPDATE nashvillehousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress)+1, length(PropertyAddress));


-- Parsing OwnerAddress into Individual Columns

Select owneraddress
From nashvillehousing;

Select
SUBSTRING_INDEX(owneraddress, ',', 1) as Address,
SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 2), ',', -1) as City,
SUBSTRING_INDEX(owneraddress, ',', -1) as State
From nashvillehousing;

ALTER Table nashvillehousing
Add OwnerSplitAddress nvarchar(255);

UPDATE nashvillehousing
Set OwnerSplitAddress = SUBSTRING_INDEX(owneraddress, ',', 1);

ALTER Table nashvillehousing
Add OwnerSplitCity nvarchar(255);

UPDATE nashvillehousing
Set OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 2), ',', -1);

ALTER Table nashvillehousing
Add OwnerSplitState nvarchar(255);

UPDATE nashvillehousing
Set OwnerSplitState = SUBSTRING_INDEX(owneraddress, ',', -1);


-- Converting Y/N to Yes/No in SoldAsVacant

Select Distinct (SoldAsVacant), Count(SoldAsVacant)
From nashvillehousing
Group by SoldAsVacant
Order by 2;

	-- replacing the y and n 
Select SoldAsVacant,
	CASE When SoldAsVacant = 'Y' Then 'Yes'
		 When SoldAsVacant = 'N' Then 'No'
         Else SoldAsVacant
         END
From nashvillehousing;

	-- updating the table for SoldAsVacant column
UPDATE nashvillehousing
Set SoldAsVacant = 
	CASE When SoldAsVacant = 'Y' Then 'Yes'
		 When SoldAsVacant = 'N' Then 'No'
         Else SoldAsVacant
         END;


-- Removing Duplicate Rows

WITH RowNumCTE As (
Select *,
	ROW_NUMBER() OVER (
    Partition By ParcelID,
				 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 Order By 
					UniqueID
                 ) rowNum
From nashvillehousing
)
Select *

-- DELETE
-- From nashvillehousing USING nashvillehousing
-- JOIN RowNumCTE On nashvillehousing.UniqueID = RowNumCTE.UniqueID

From RowNumCTE
Where rowNum > 1
Order By PropertyAddress;


-- Delete Unused Columns

ALTER Table nashvillehousing
DROP Column OwnerAddress,
DROP Column PropertyAddress,
DROP Column TaxDistrict;
