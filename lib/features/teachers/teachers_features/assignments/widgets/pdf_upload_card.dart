import 'package:flutter/material.dart';
import 'package:nexcampus_app/core/constants/app_theme.dart';

class PdfUploadCard extends StatelessWidget {

  final bool isUploading;
  final String? pdfName;
  final VoidCallback onTap;


  const PdfUploadCard({
    super.key,
    required this.isUploading,
    required this.pdfName,
    required this.onTap,
  });


  @override
  Widget build(BuildContext context) {

    final width =
        MediaQuery.of(context).size.width;

    final isTablet =
        width >= 600;


    final uploaded =
        pdfName != null;



    return Column(

      crossAxisAlignment:
          CrossAxisAlignment.start,


      children: [


        Text(

          "Assignment PDF",


          style:
              TextStyle(

                fontWeight:
                    FontWeight.bold,

                fontSize:
                    isTablet ? 17 : 15,
              ),
        ),



        SizedBox(

          height:
              isTablet ? 12 : 8,
        ),




        Card(

          elevation:
              3,


          shape:
              RoundedRectangleBorder(

                borderRadius:
                    BorderRadius.circular(
                      isTablet ? 20 : 16,
                    ),
              ),




          child: InkWell(

            borderRadius:
                BorderRadius.circular(
                  isTablet ? 20 : 16,
                ),



            onTap:
                isUploading ? null : onTap,



            child: Padding(

              padding:
                  EdgeInsets.all(
                    isTablet ? 22 : width * 0.045,
                  ),



              child: Row(

                crossAxisAlignment:
                    CrossAxisAlignment.center,



                children: [



                  CircleAvatar(

                    radius:
                        isTablet ? 30 : 26,


                    backgroundColor:

                        uploaded

                            ? Colors.green.shade100

                            : Colors.red.shade100,



                    child:


                    isUploading

                        ? SizedBox(

                            width:
                                isTablet ? 26 : 22,


                            height:
                                isTablet ? 26 : 22,


                            child:
                                const CircularProgressIndicator(

                                  strokeWidth:
                                      2,
                                ),
                          )



                        : Icon(

                            uploaded

                                ? Icons.check

                                : Icons.picture_as_pdf,


                            color:

                                uploaded

                                    ? Colors.green

                                    : Colors.red,


                            size:
                                isTablet ? 32 : 26,
                          ),
                  ),




                  SizedBox(

                    width:
                        width * 0.035,
                  ),





                  Expanded(

                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment.start,



                      children: [



                        Text(

                          pdfName ??
                              "Upload Assignment PDF",



                          maxLines:
                              2,


                          overflow:
                              TextOverflow.ellipsis,



                          style:
                              TextStyle(

                                fontWeight:
                                    FontWeight.bold,


                                fontSize:
                                    isTablet ? 18 : 16,
                              ),
                        ),




                        const SizedBox(
                          height: 5,
                        ),




                        Text(

                          isUploading

                              ? "Uploading..."

                              : uploaded

                                  ? "PDF uploaded successfully"

                                  : "Tap to choose a PDF",



                          maxLines:
                              2,


                          overflow:
                              TextOverflow.ellipsis,



                          style:
                              TextStyle(

                                color:
                                    Colors.grey.shade600,


                                fontSize:
                                    isTablet ? 15 : 13,
                              ),
                        ),
                      ],
                    ),
                  ),




                  SizedBox(

                    width:
                        width * 0.02,
                  ),




                  Icon(

                    uploaded

                        ? Icons.edit

                        : Icons.upload_file,


                    color:
                        AppTheme.primary,


                    size:
                        isTablet ? 28 : 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}