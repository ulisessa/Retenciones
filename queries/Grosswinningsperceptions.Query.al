query 50036 "Gross winnings perceptions"
{

    elements
    {
        dataitem(Vendor_Ledger_Entry; "Vendor Ledger Entry")
        {
            filter(Posting_Date_filter; "Document Date")
            {
            }
            filter(Vendor_No_filter; "Vendor No.")
            {
            }
            column(Vendor_No; "Vendor No.")
            {
            }
            column(Document_Date; "Document Date")
            {
            }
            column(Currency_Code; "Currency Code")
            {
            }
            column(Sum_Amount; Amount)
            {
                Method = Sum;
            }
            column(Sum_Amount_LCY; "Amount (LCY)")
            {
                Method = Sum;
            }
            column(External_Document_No; "External Document No.")
            {
            }
            dataitem(Res_Ledger_Entry; "Res. Ledger Entry")
            {
                DataItemLink = "Document No." = Vendor_Ledger_Entry."Document No.", "Source No." = Vendor_Ledger_Entry."Vendor No.";
                column(Document_No; "Document No.")
                {
                }
                column(Resource_No; "Resource No.")
                {
                }
                column(Source_No; "Source No.")
                {
                }
                column(Sum_Total_Cost; "Total Cost")
                {
                    Method = Sum;
                }
                dataitem(Resource; Resource)
                {
                    DataItemLink = "No." = Res_Ledger_Entry."Resource No.";
                    column(Gross_winnings_perception_code; "Gross winnings perception code")
                    {
                        ColumnFilter = Gross_winnings_perception_code = FILTER (<> '');
                    }
                    dataitem(Vendor; Vendor)
                    {
                        DataItemLink = "No." = Vendor_Ledger_Entry."Vendor No.";
                        column(VAT_Registration_No; "VAT Registration No.")
                        {
                        }
                    }
                }
            }
        }
    }
}

