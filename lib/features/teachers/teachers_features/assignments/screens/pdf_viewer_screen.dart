import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:nexcampus_app/core/constants/app_theme.dart';


class PdfViewerScreen extends StatelessWidget {

  final String pdfUrl;
  final String title;


  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.title,
  });



  @override
  Widget build(BuildContext context) {


    final width =
        MediaQuery.of(context).size.width;


    final bool isTablet =
        width >= 600;



    return Scaffold(

      backgroundColor:
          const Color(0xffF5F7FA),



      appBar: AppBar(

        backgroundColor:
            AppTheme.primary,


        foregroundColor:
            Colors.white,


        title:

        Text(

          title,

          maxLines: 1,

          overflow:
              TextOverflow.ellipsis,

          style:

          TextStyle(

            fontSize:
                isTablet ? 20 : 18,

          ),

        ),

      ),



      body:

      SafeArea(

        child:

        Container(

          margin:

          EdgeInsets.symmetric(

            horizontal:
                isTablet ? 20 : 0,

            vertical:
                isTablet ? 15 : 0,

          ),


          decoration:

          BoxDecoration(

            color:
                Colors.white,


            borderRadius:

            BorderRadius.circular(

              isTablet ? 20 : 0,

            ),

          ),



          clipBehavior:
              Clip.antiAlias,



          child:

          SfPdfViewer.network(

            pdfUrl,


            canShowScrollHead:
                true,


            canShowScrollStatus:
                true,


            enableDoubleTapZooming:
                true,


            onDocumentLoaded:
                (details){

              debugPrint(
                "PDF Loaded Successfully",
              );

            },



            onDocumentLoadFailed:
                (details){

              debugPrint(
                details.error,
              );

              debugPrint(
                details.description,
              );

            },


          ),

        ),

      ),

    );

  }

}