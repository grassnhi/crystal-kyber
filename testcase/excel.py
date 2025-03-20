import pandas as pd

def convert_hex_to_decimal(input_file, output_file):
    """
    Converts hexadecimal values to decimal in an Excel file.
    
    Parameters:
        input_file (str): Path to the input Excel file.
        output_file (str): Path to save the modified Excel file with decimal values.
    """
    # Load the Excel file
    excel_data = pd.read_excel(input_file, sheet_name=None)  # Load all sheets

    # Iterate over each sheet and convert hex values to decimal
    for sheet_name, sheet_data in excel_data.items():
        for col in sheet_data.columns:
            # Convert cells with hex values to decimal
            sheet_data[col] = sheet_data[col].apply(
                lambda x: int(str(x), 16) if isinstance(x, str) and x.startswith('0x') else x
            )

    # Save the modified data to a new Excel file
    with pd.ExcelWriter(output_file) as writer:
        for sheet_name, sheet_data in excel_data.items():
            sheet_data.to_excel(writer, sheet_name=sheet_name, index=False)

# Example usage
input_file = "C:\Users\Admin\Downloads\TMT.xlsx"
output_file = "C:\Users\Admin\Downloads\TMT_converted_to_decimal.xlsx"
convert_hex_to_decimal(input_file, output_file)