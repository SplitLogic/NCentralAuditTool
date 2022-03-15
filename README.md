# NCentralAuditTool

This tool is incomplete and is only partially functional.

This is designed to pull information from N-Central and export it to a CSV. There is also a function to generate a processor list to calculate hardware age for the audit.

Generate your JWT and input your server at the top of the code and you can then use it to pull information.

Still to do:
1. Change W11 Readyness check - I changed from Monitoring to custom property (it was a sea of red) but have yet to modify the code.
2. CPU list is incomplete - need to find a better way to generate the list
3. When running against all customers it runs it twice due to the customer list containing customer and site.
4. Have difficulty calculating hardware age from processor release - It just does the one and feeds it to all records below.
5. I want to use the warranty date for the hardware age instead of CPU where possible. Need to program in a way to calculate age from warranty and if the warranty info isnt available use the processor.

If requested i can provide the AMP's used for the KFM enable check and W11 readyness check. Upload them to this Git

If anyone is able to help develop this further please get in touch.
