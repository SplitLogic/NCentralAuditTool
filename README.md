# NCentralAuditTool

This tool is incomplete and is only partially functional.

![image](https://user-images.githubusercontent.com/1890606/158362984-86e4989e-09fc-40fd-a52c-d389f99c0295.png)

This is designed to pull information from N-Central and export it to a CSV. There is also a function to generate a processor list to calculate hardware age for the audit.

Generate your JWT and input your server at the top of the code and you can then use it to pull information.

Still to do:
2. CPU list is incomplete - need to find a better way to generate a more complete list.
4. Have difficulty calculating hardware age from processor release - It just does the one and feeds it to all records below.
5. I want to use the warranty date for the hardware age instead of CPU where possible. Need to program in a way to calculate age from warranty and if the warranty info isnt available use the processor.
6. Code efficiency sucks - there are better ways to do some of things ive done. Needs tidying, there are repeated functions in the script.

AMP files provided for N-Central property updates.

If anyone is able to help develop this further please get in touch. I think the ultimate aim is to make everything work and potentially even get to a GUI.

Not possible without the fantastic PS-NCentral tool you can find more information on here https://github.com/ToschAutomatisering/PS-NCentral. Massive thanks for their work on the module.

Note: Requires Powershell 7.
