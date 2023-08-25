/* Q1: Who is the senior most employee based on job title? */
Select *
From Employee
Order by Hire_date
Limit 1;

/* Q2: Which countries have the most Invoices? */
Select Count(*) As C,
	Billing_country
From Invoice
Group by Billing_country
Order by C Desc;

/* Q3: What are top 3 values of total invoice? */
Select Total
From Invoice
Order by Total Desc;

/* Q4: Which city has the best customers? We would like to throw a promotional Music
Festival in the city we made the most money.
Write a query that returns one city that has the highest sum of invoice totals.
Return both the city name & sum of all invoice totals */
Select Billing_city,
	Sum(Total) As Invoicetotal
From Invoice
Group by Billing_city
Order by Invoicetotal Desc
Limit 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be
declared the best customer.
Write a query that returns the person who has spent the most money.*/
Select Customer.Customer_id,
	First_name,
	Last_name,
	Sum(Total) As Total_spending
From Customer
Join Invoice On Customer.Customer_id = Invoice.Customer_id
Group by Customer.Customer_id
Order by Total_spending Desc
Limit 1;

/* Q6: Write query to return the email, first name, last name, & Genre of all Rock
Music listeners.
Return your list ordered alphabetically by email starting with A. */
Select C.Email,
	C.First_name,
	C. Last_name,
	G.Name As Genre
From Customer C
Join Invoice I On I.Customer_id = C.Customer_id
Join Invoice_line Il On Il.Invoice_id = I.Invoice_id
Join Track T On T.Track_id = Il.Track_id
Join Genre G On G.Genre_id = T.Genre_id
Where G. Name like 'Rock'
Group by 1,2,
	3,4
Order by 1;

/* OR */
Select Distinct C.Email,
	C.First_name,
	C. Last_name,
	G.Name As Genre
From Customer C
Join Invoice I On I.Customer_id = C.Customer_id
Join Invoice_line Il On Il.Invoice_id = I.Invoice_id
Join Track T On T.Track_id = Il.Track_id
Join Genre G On G.Genre_id = T.Genre_id
Where G. Name like 'Rock'
Order by 1;

/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */ 
Select A.Name As Artist_name, 
	Count(G.Name) As Count_of_songs
From Artist A
Join Album Al On Al.Artist_id = A.Artist_id
Join Track T On T.Album_id = Al.Album_id
Join Genre G On G.Genre_id = T.Genre_id 
Where G.Name like 'Rock'
Group by 1
Order by 2 Desc
Limit 10;

/* Q8: Return all the track names that have a song length longer than the average song length.
Return the Name and Milliseconds for each track. Order by the song length with the longest
songs listed first. */
Select Name As Track_name,
	Milliseconds
From Track
Where Milliseconds >
		(Select Avg(Milliseconds)
			From Track)
Order by 2 Desc;

/* Q9: Find how much amount spent by each customer on artists?
Write a query to return customer name, artist name and total spent */
Select C.First_name,
	Ar.Name,
	Sum(Il.Unit_price * Il.Quantity) As Totalspent
From Customer C
Join Invoice On Invoice.Customer_id = C.Customer_id
Join Invoice_line Il On Il.Invoice_id = Invoice.Invoice_id
Join Track T On T.Track_id = Il.Track_id
Join Album A On A.Album_id = T.Album_id
Join Artist Ar On Ar.Artist_id = A.Artist_id
Group by 1,2
Order by 3 Desc;

/* Q10: We want to find out the most popular music Genre for each country. We determine the
most popular genre as the genre with the highest amount of purchases.
Write a query that returns each country along with the top Genre. For countries where
the maximum number of purchases is shared return all Genres. */ 

With Table1 As
	(Select Count(*)As Purchases,
			Customer.Country,
			Genre.Name,
			Genre.Genre_id
		From Invoice_line
		Join Invoice On Invoice.Invoice_id = Invoice_line.Invoice_id
		Join Customer On Customer.Customer_id = Invoice.Customer_id
		Join Track On Track.Track_id = Invoice_line.Track_id
		Join Genre On Genre.Genre_id = Track.Genre_id
		Group by 2,3,
			4)
Select Max(Purchases) As Amt_of_purchase,
	Country,
	Name As Popular_genre,
	Genre_id
From Table1
Group by 2,3,
	4
Order by 1 Desc;

/* Q11: Write a query that determines the customer that has spent the most on music for each country.
Write a query that returns the country along with the top customer and how much they spent.*/
With Customerspent As
	(Select C.Customer_id,
			C.First_name,
			C.Last_name,
			I.Billing_country,
			Sum(I.Total) As Total_purchase,
			Row_number() Over (Partition By I.Billing_country Order by Sum (I.Total))
		From Customer C
		Join Invoice I On C.Customer_id = I.Customer_id
		Group by 1,2,
			3,4
		Order by 4)
Select Customer_id,
	First_name,
	Last_name,
	Billing_country,
	Total_purchase
From Customerspent
Where Row_number = 1
Order by Total_purchase Desc;

/* Q12: Write a query to fetch Top 3 artist from the each countries.
   Write a query to return artist name and their business*/
With Country_sales As
	(Select A.Artist_id,
			A.Name,
			Count(T.Track_id)As No_of_track,
			I.Billing_country As Country,
			Sum(Il.Unit_price * Il.Quantity)As Total_sale,
			Dense_rank () Over (Partition By I.Billing_country
			Order by Sum(Il.Unit_price * Il.Quantity) Desc) As Top_3
		From Artist A
		Join Album Al On A.Artist_id = Al.Artist_id
		Join Track T On Al.Album_id = T.Album_id
		Join Invoice_line Il On Il.Track_id = T.Track_id
		Join Invoice I On Il.Invoice_id = I.Invoice_id
		Group by 1,2,
			4
		Order by 4)
Select *
From Country_sales
Where Top_3 <= 3;

/* Q13: Write a query to group countries under high to low sales according to their Total sales*/

Select No_of_invoice,
	Billing_country,
	Total_sales,
	Case
					When N = 1 Then 'High Sales'
					When N = 2 Then 'Mid Sales'
					When N = 3 Then 'Low Sales'
	End As Group
From
	(Select Count (Invoice_id) As No_of_invoice,
			Billing_country,
			Sum(Total) As Total_sales,
			Ntile(3) Over (
			Order by Sum(Total) Desc Range Between Unbounded Preceding And Unbounded Following) As N
		From Invoice
		Group by 2
		Order by 4,3 Desc) As A

