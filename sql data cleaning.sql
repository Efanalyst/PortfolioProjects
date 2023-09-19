use [data cleaning]

-- cleaning data in sql

select * 
from [dbo].[Nashville Housing]

-- populate property address
select *
from [dbo].[Nashville Housing]
where PropertyAddress is null


select a.ParcelID, b.PropertyAddress, b.ParcelID, a.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from [dbo].[Nashville Housing] a
join [dbo].[Nashville Housing] b
on a.ParcelID =b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from [dbo].[Nashville Housing] a
join [dbo].[Nashville Housing] b
on a.ParcelID =b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


--Breaking out property address into individual column(address, city, state)

select PropertyAddress
from [dbo].[Nashville Housing]

select SUBSTRING(PropertyAddress, 1, charindex(',',PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress, charindex(',',PropertyAddress)+1, len(propertyaddress)) as address
from [dbo].[Nashville Housing]

alter table [dbo].[Nashville Housing]
add PropertysplitAddress nvarchar(255)

update [dbo].[Nashville Housing]
set PropertysplitAddress = SUBSTRING(PropertyAddress, 1, charindex(',',PropertyAddress)-1) 

alter table [dbo].[Nashville Housing]
add Propertysplitcity nvarchar(255)

update [dbo].[Nashville Housing]
set Propertysplitcity  = SUBSTRING(PropertyAddress, charindex(',',PropertyAddress)+1, len(propertyaddress)) 


select OwnerAddress
from [dbo].[Nashville Housing]

select 
	PARSENAME(replace(OwnerAddress,',','.'),3),
	PARSENAME(replace(OwnerAddress,',','.'),2),
	PARSENAME(replace(OwnerAddress,',','.'),1)
from [dbo].[Nashville Housing]

alter table [dbo].[Nashville Housing]
add OwnersplitAddress nvarchar(255)

update [dbo].[Nashville Housing]
set OwnersplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

alter table [dbo].[Nashville Housing]
add Ownersplitcity nvarchar(255)

update [dbo].[Nashville Housing]
set Ownersplitcity  = PARSENAME(replace(OwnerAddress,',','.'),2) 

alter table [dbo].[Nashville Housing]
add Ownersplitstate nvarchar(255)

update [dbo].[Nashville Housing]
set Ownersplitstate  = PARSENAME(replace(OwnerAddress,',','.'),1)

--Change "1" and "0" to "yes" and "no" in 'SoldAsVacant'

select distinct(SoldAsVacant), count(SoldAsVacant)
from [dbo].[Nashville Housing]
group by SoldAsVacant


select sum(cast(SoldAsVacant as int))
from [dbo].[Nashville Housing]


select SoldAsVacant,
	CASE 
	when SoldAsVacant = '0' then 'no'
	when SoldAsVacant = '1' then 'yes'
	else str(convert(varchar, convert(int, SoldAsVacant)))
	end as soldasvacantNEW
from [dbo].[Nashville Housing]

update [dbo].[Nashville Housing]
set SoldAsVacant = CASE 
	when SoldAsVacant = '0' then 'no'
	else str(convert(varchar, convert(int, SoldAsVacant)))
	end 
	-- to be completed
	

--Remove duplicates
with ROWnumCte as(
select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
				 UniqueID
				 ) row_num
from [dbo].[Nashville Housing])
					  --order by ParcelID
select * 
from ROWnumCte
where row_num > 1
order by PropertyAddress

with ROWnumCte as(
select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
				 UniqueID
				 ) row_num
from [dbo].[Nashville Housing])
					  --order by ParcelID
delete 
from ROWnumCte
where row_num > 1
--order by PropertyAddress


-- Delete Unused columns(not raw data)


select  *
from [dbo].[Nashville Housing]

alter table [dbo].[Nashville Housing]
drop column PropertyAddress, OwnerAddress, TaxDistrict, SaleDate

alter table [dbo].[Nashville Housing]
drop column SaleDate
