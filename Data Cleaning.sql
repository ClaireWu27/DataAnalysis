/*cleaning data for sql queries*/

select *
from NashvilleHousing nh;

--  standardize date format
select SaleDate, str_to_date(SaleDate,"%M %e,%Y") as FormattedSaleDate
from NashvilleHousing nh;

update NashvilleHousing 
set SaleDate=str_to_date(SaleDate,"%M %e,%Y");

-- populate property address data
select  a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ifnull(a.PropertyAddress, b.PropertyAddress) 
from NashvilleHousing a join NashvilleHousing b
on a.ParcelID =b.ParcelID and a.UniqueID !=b.UniqueID
where a.PropertyAddress="";
update NashvilleHousing a
join NashvilleHousing b
on a.ParcelID =b.ParcelID and a.UniqueID !=b.UniqueID
set a.PropertyAddress=ifnull(a.PropertyAddress,b.PropertyAddress)
where a.PropertyAddress="";

-- breaking out address into individual columns (address, city)
select substring_index(PropertyAddress,',',1) as Address,substring_index(PropertyAddress,',',-1)  as City
from NashvilleHousing nh ;

alter table NashvilleHousing 
add column PropertySplitAddress varchar(255);

update NashvilleHousing 
set PropertySplitAddress=substring_index(PropertyAddress,',',1);
alter table NashvilleHousing
add column PropertySplitCity varchar(255);

update NashvilleHousing 
set PropertySplitCity=substring_index(PropertyAddress,',',-1);

select *
from NashvilleHousing nh ;

-- breaking out address into individual columns (address, city,state)
select OwnerAddress 
from NashvilleHousing nh ;

select OwnerAddress, substring_index(OwnerAddress,',',1) as Address,substring_index(substring_index(OwnerAddress,',',2) ,',',-1) as City,substring_index(OwnerAddress,',',-1) as State
from NashvilleHousing nh ;


alter table NashvilleHousing 
add column OwnerSplitAddress varchar(255);

update NashvilleHousing 
set OwnerSplitAddress=substring_index(OwnerAddress,',',1);

alter table NashvilleHousing 
add column OwnerSplitCity varchar(255);

update NashvilleHousing 
set OwnerSplitCity=substring_index(substring_index(OwnerAddress,',',2) ,',',-1);

alter table NashvilleHousing 
add column OwnerSplitState varchar(255);

update NashvilleHousing 
set OwnerSplitState=substring_index(OwnerAddress,',',-1) ;

select *
from NashvilleHousing ;

-- change Y and N to Yes and No in "sold as Vacant" field
select distinct (SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing 
group by SoldAsVacant 
order by SoldAsVacant ;

select SoldAsVacant,
case when SoldAsVacant ='Y' then 'Yes'
     when SoldAsVacant ='N' then 'No'
     else SoldAsVacant
end
from NashvilleHousing nh ;

update NashvilleHousing 
set SoldAsVacant =
case 
	 when SoldAsVacant ='Y' then 'Yes'
     when SoldAsVacant ='N' then 'No'
     else SoldAsVacant
end;

select SoldAsVacant, count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant ;

-- remove duplicates

DELETE FROM NashvilleHousing
WHERE UniqueID NOT IN (
    SELECT minUniqueID
    FROM (
        SELECT min(UniqueID) as minUniqueID
        FROM NashvilleHousing
        GROUP BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
    ) AS subquery
);

-- delete unused columns
alter table NashvilleHousing 
drop column OwnerAddress,
drop column TaxDistrict,
drop column PropertyAddress;

select *
from NashvilleHousing;
