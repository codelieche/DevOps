## 导出excel文件



- 采用openpyxl导出xlsx文件

  安装 `pip install openpyxl`

```python
import openpyxl
from rest_framework.views import APIView
from django.http.response import HttpResponse

class ExceptExcelFileApiView(APIView):
    """
    导出excel文件
    """
    def get(self, request):
        # 现在创建excle文件
        wbook = openpyxl.Workbook()
        wsheet = wbook.create_sheet(title="Sheet1", index=0)
        
        row = 1
        set_width_flag = True
        for values in [("id", "name", "age")s, (1, "U01", 18), (2, "User02", 28)]:
            colum = 1
            for value in values:
                if set_width_flag:
                    # 设置列的宽 
                    col = wsheet.column_dimensions[chr(ord('A') + colum - 1)]
                    col.width = 20
                wsheet.cell(row=row, column=colum, value=value)
                colum += 1
            set_width_flag = False
            row += 1

        response = HttpResponse(content_type="application/vnd.ms-excel")
        response["Content-Disposition"] = 'attachment;filename=demo.xlsx'
        wbook.save(response)
        return response

```



- 采用xlwt操作excel

  安装：`pip install xlwt`

```python
import xlwt
from rest_framework.views import APIView
from django.http.response import HttpResponse

class ExceptExcelFileApiView(APIView):
    """
    导出excel文件
    """
    def get(self, request):
        # 现在创建excle文件
        wbook = xlwt.Workbook(encoding="utf-8")
        wsheet = wbook.add_sheet(sheetname="sheet1")
        row = 0
        set_width_flag = True
        for values in [("id", "name", "age")s, (1, "U01", 18), (2, "User02", 28)]:
            colum = 0
            for value in values:
                if set_width_flag:
                    col = wsheet.col(colum)
                    col.width = 256 * 20
                wsheet.write(row, colum, value)  
                colum += 1
            set_width_flag = False
            row += 1

        response = HttpResponse(content_type="application/vnd.ms-excel")
        response["Content-Disposition"] = 'attachment;filename=demo.xlsx'
        wbook.save(filename_or_stream=response)
        return response

```

