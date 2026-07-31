import 'package:flutter/material.dart';

class PdfAttachmentCard extends StatelessWidget {

  final String fileName;
  final VoidCallback onView;
  final VoidCallback onDownload;


  const PdfAttachmentCard({
    super.key,
    required this.fileName,
    required this.onView,
    required this.onDownload,
  });


  @override
  Widget build(BuildContext context) {

    final width =
        MediaQuery.of(context).size.width;

    final isTablet =
        width >= 600;


    return Card(

      elevation: 3,

      shape:
          RoundedRectangleBorder(

            borderRadius:
                BorderRadius.circular(
                  isTablet ? 20 : 16,
                ),
          ),


      child: Padding(

        padding:
            EdgeInsets.all(
              isTablet ? 20 : width * 0.04,
            ),


        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,


          children: [


            /// PDF HEADER
            Row(

              crossAxisAlignment:
                  CrossAxisAlignment.start,


              children: [


                CircleAvatar(

                  radius:
                      isTablet ? 28 : 24,


                  backgroundColor:
                      const Color(0xffFDECEC),


                  child: Icon(

                    Icons.picture_as_pdf,

                    color:
                        Colors.red,

                    size:
                        isTablet ? 32 : 28,
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

                        "Attached PDF",


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

                        fileName,


                        maxLines: 2,


                        overflow:
                            TextOverflow.ellipsis,


                        style:
                            TextStyle(

                              fontSize:
                                  isTablet ? 16 : 14,

                              color:
                                  Colors.grey.shade700,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),



            SizedBox(

              height:
                  isTablet ? 24 : width * 0.05,
            ),




            /// ACTION BUTTONS
            LayoutBuilder(

              builder: (context, constraints) {


                final smallWidth =
                    constraints.maxWidth < 350;



                if (smallWidth) {

                  return Column(

                    children: [


                      SizedBox(

                        width:
                            double.infinity,


                        child:
                            _viewButton(),
                      ),



                      const SizedBox(
                        height: 12,
                      ),



                      SizedBox(

                        width:
                            double.infinity,


                        child:
                            _downloadButton(),
                      ),
                    ],
                  );
                }



                return Row(

                  children: [


                    Expanded(

                      child:
                          _viewButton(),
                    ),



                    const SizedBox(
                      width: 12,
                    ),



                    Expanded(

                      child:
                          _downloadButton(),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }





  Widget _viewButton() {

    return OutlinedButton.icon(

      onPressed:
          onView,


      icon:
          const Icon(
            Icons.visibility,
          ),


      label:
          const Text(
            "View",
          ),
    );
  }





  Widget _downloadButton() {

    return ElevatedButton.icon(

      onPressed:
          onDownload,


      icon:
          const Icon(
            Icons.download,
          ),


      label:
          const Text(
            "Download",
          ),
    );
  }
}