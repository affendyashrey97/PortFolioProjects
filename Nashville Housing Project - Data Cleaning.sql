/*

Cleaning Data in SQL Queries

*/

Select *
From NashvilleHousing
--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select Saledate, Convert(Date,Saledate)
from NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(Date,Saledate)

Alter table NashvilleHousing
Alter column SaleDate date

Select *
From NashvilleHousing

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From NashvilleHousing
where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing as a
join NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress) 
From NashvilleHousing as a
join NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select *
From NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) City
From NashvilleHousing

Alter table NashvilleHousing
Add PropertySpiltAddress nvarchar(255);

Update NashvilleHousing
Set PropertySpiltAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

Alter table NashvilleHousing
Add City nvarchar(255);

Update NashvilleHousing
Set City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select *
From NashvilleHousing

Select OwnerAddress
From NashvilleHousing

Select Parsename(Replace(OwnerAddress, ',', '.'), 3) OwnerSplitAddress
, Parsename(Replace(OwnerAddress, ',', '.'), 2) OwnerSplitCity
, Parsename(Replace(OwnerAddress, ',', '.'), 1) OwnerSplitState
From NashvilleHousing

Alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',', '.'), 3)

Alter table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = Parsename(Replace(OwnerAddress, ',', '.'), 2)

Alter table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = Parsename(Replace(OwnerAddress, ',', '.'), 1)

Select *
From NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct SoldAsVacant, COUNT(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2

Select Distinct SoldAsVacant, 
Case
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
End
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant =
Case
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
End

Select Distinct SoldAsVacant, COUNT(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with rownumcte as (
Select *,
	row_number() over (partition by  parcelid, propertyaddress, saleprice,saledate,legalreference order by Uniqueid) row_num
from NashvilleHousing)
Delete 
from rownumcte
where row_num > 1

with rownumcte as (
Select *,
	row_number() over (partition by  parcelid, propertyaddress, saleprice,saledate,legalreference order by Uniqueid) row_num
from NashvilleHousing)
Select * 
from rownumcte
where row_num > 1

Select * 
From NashvilleHousing

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Alter table NashvilleHousing
Drop column Propertyaddress, Owneraddress, taxdistrict

Select * 
From NashvilleHousing

Alter table NashvilleHousing
Drop column saledate

Select * 
From NashvilleHousing

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO
