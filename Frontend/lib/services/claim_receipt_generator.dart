import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ClaimReceiptGenerator {

  static const _navy  = PdfColor(0.102, 0.180, 0.431); // #1A2E6E
  static const _gold  = PdfColor(0.961, 0.651, 0.137); // #F5A623
  static const _green = PdfColor(0.0,   0.784, 0.325); // #00C853
  static const _light = PdfColor(0.910, 0.929, 1.000); // #E8EDFF
  static const _dark  = PdfColor(0.051, 0.094, 0.161); // #0D1829
  static const _gray  = PdfColor(0.478, 0.545, 0.690); // #7A8BB0
  static const _bdr   = PdfColor(0.804, 0.847, 0.965); // #CDD8F6

  static String _month(int m) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m];
  }

  static String _formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2,'0')} ${_month(d.month)} ${d.year}';

  static String _formatTime(DateTime d) {
    final h = d.hour > 12 ? d.hour - 12 : d.hour == 0 ? 12 : d.hour;
    final m = d.minute.toString().padLeft(2,'0');
    final s = d.second.toString().padLeft(2,'0');
    final p = d.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m:$s $p IST';
  }

  static Future<void> generate({
    required int                        total,
    required List<Map<String, dynamic>> triggers,
    required List<int>                  amounts,
    required Map<String, dynamic>?      policy,
    required String                     upiId,
    required String                     claimId,
    required String                     txnId,
    required bool                       isFraud,
  }) async {
    final font     = await PdfGoogleFonts.notoSansRegular();
    final fontBold = await PdfGoogleFonts.notoSansBold();
    final pdf      = pw.Document(
      theme: pw.ThemeData.withFont(base: font, bold: fontBold),
    );

    final now        = DateTime.now();
    final dateStr    = _formatDate(now);
    final timeStr    = _formatTime(now);
    final workerName = policy?['name']     ?? 'worker';
    final workerPhone = policy?['phone']   ?? '';
    final derivedUpi = '${workerName.toString().replaceAll(' ', '').toLowerCase()}${workerPhone.toString().replaceAll(' ', '')}@upi';
    final zone       = policy?['zone']     ?? 'Your Zone';
    final platform   = policy?['platform'] ?? 'Zepto';
    final plan       = (policy?['plan_type'] ?? 'standard').toUpperCase();
    final wid        = policy?['id'] ?? 1;
    final policyNo   = 'GS-${now.year}-${now.month.toString().padLeft(2,'0')}-${wid.toString().padLeft(5,'0')}';

    final bannerColor = isFraud ? _gold : const PdfColor(0.35, 0.75, 0.35); // light green for success, gold for failure
    final titleText   = isFraud ? 'Failure' : 'Success';
    final titleColor  = isFraud ? const PdfColor(0.96, 0.3, 0.2) : const PdfColor(0.1, 0.5, 0.1); // red-orange vs dark green
    final subText     = isFraud ? 'Claim Failed' : 'Claim Successful';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin:     const pw.EdgeInsets.all(0),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [

            // ── Dark header ──────────────────────────────
            pw.Container(
              width:   double.infinity,
              padding: const pw.EdgeInsets.fromLTRB(40, 28, 40, 28),
              color:   _dark,
              child:   pw.Row(
                mainAxisAlignment:
                  pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment:
                      pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('RozgarShield',
                        style: pw.TextStyle(
                          color:      PdfColors.white,
                          fontSize:   26,
                          fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Income Protection for India\'s Gig Workers',
                        style: const pw.TextStyle(
                          color:    PdfColors.white,
                          fontSize: 10)),
                      pw.SizedBox(height: 14),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment:
                      pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('CLAIM RECEIPT',
                        style: pw.TextStyle(
                          color:      _gold,
                          fontSize:   18,
                          fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 6),
                      pw.Text(claimId,
                        style: const pw.TextStyle(
                          color:    PdfColors.white,
                          fontSize: 10)),
                      pw.SizedBox(height: 3),
                      pw.Text(dateStr,
                        style: const pw.TextStyle(
                          color:    PdfColors.white,
                          fontSize: 9)),
                      pw.Text(timeStr,
                        style: const pw.TextStyle(
                          color:    PdfColors.white,
                          fontSize: 9)),
                    ],
                  ),
                ],
              ),
            ),

            // ── Banner ───────────────────────
            pw.Container(
              width:   double.infinity,
              padding: const pw.EdgeInsets.symmetric(
                vertical: 18, horizontal: 40),
              color:   bannerColor,
              child:   pw.Row(
                mainAxisAlignment:
                  pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Column(
                    crossAxisAlignment:
                      pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(subText,
                        style: pw.TextStyle(
                          color:    _navy,
                          fontSize: 11)),
                      pw.SizedBox(height: 4),
                      pw.Text(titleText,
                        style: pw.TextStyle(
                          color:      titleColor,
                          fontSize:   34,
                          fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment:
                      pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('via UPI',
                        style: pw.TextStyle(
                          color:    _navy,
                          fontSize: 10)),
                      pw.SizedBox(height: 4),
                      pw.Text(derivedUpi,
                        style: pw.TextStyle(
                          color:      _navy,
                          fontSize:   13,
                          fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 3),
                      pw.Text('Settled in under 60 seconds',
                        style: pw.TextStyle(
                          color:    _navy,
                          fontSize: 9)),
                    ],
                  ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────
            pw.Expanded(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(36),
                child:   pw.Column(
                  crossAxisAlignment:
                    pw.CrossAxisAlignment.start,
                  children: [

                    // Two info boxes
                    pw.Row(
                      crossAxisAlignment:
                        pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(child: _infoBox(
                          title: 'Policyholder',
                          items: [
                            ['Name',     workerName],
                            ['Platform', platform],
                            ['Zone',     zone],
                            ['Plan',     plan],
                          ],
                        )),
                        pw.SizedBox(width: 16),
                        pw.Expanded(child: _infoBox(
                          title: 'Policy Details',
                          items: [
                            ['Policy No', policyNo],
                            ['Claim ID',  claimId],
                            ['Txn ID',    txnId],
                            ['Date',      dateStr],
                          ],
                        )),
                      ],
                    ),

                    pw.SizedBox(height: 20),

                    // Breakdown table
                    _sectionTitle('Claim Breakdown'),
                    pw.SizedBox(height: 8),

                    pw.Table(
                      border: pw.TableBorder.all(
                        color: _bdr, width: 0.5),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(2.5),
                        1: const pw.FlexColumnWidth(1),
                        2: const pw.FlexColumnWidth(1),
                        3: const pw.FlexColumnWidth(1.5),
                      },
                      children: [
                        pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: _navy),
                          children: [
                            _th('Trigger / Event'),
                            _th('Tier'),
                            _th('Payout %'),
                            _th('Amount'),
                          ],
                        ),
                        ...List.generate(triggers.length, (i) {
                          final t   = triggers[i];
                          final odd = i % 2 == 0;
                          final name = (t['name'] ?? t['label'] ?? t['trigger_type'] ?? 'Event').toString();
                          final severity = (t['severity'] ?? 'N/A').toString();
                          final pct = (t['pct'] ?? 100).toString();
                          return pw.TableRow(
                            decoration: pw.BoxDecoration(
                              color: odd
                                ? PdfColors.white
                                : const PdfColor(
                                    0.973, 0.980, 1.0)),
                            children: [
                              _td(name),
                              _td(severity),
                              _td('$pct%'),
                              _tdGold('Rs.${amounts[i]}'),
                            ],
                          );
                        }),
                        // Total row
                        pw.TableRow(
                          decoration: pw.BoxDecoration(
                            color: _navy),
                          children: [
                            pw.Padding(
                              padding:
                                const pw.EdgeInsets.all(8),
                              child: pw.Text('TOTAL',
                                style: pw.TextStyle(
                                  color:      PdfColors.white,
                                  fontSize:   10,
                                  fontWeight:
                                    pw.FontWeight.bold))),
                            pw.Padding(
                              padding:
                                const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                '${triggers.length} triggers',
                                style: const pw.TextStyle(
                                  color:    PdfColors.white,
                                  fontSize: 9))),
                            pw.Padding(
                              padding:
                                const pw.EdgeInsets.all(8),
                              child: pw.Text('',
                                style: const pw.TextStyle(
                                  fontSize: 9))),
                            pw.Padding(
                              padding:
                                const pw.EdgeInsets.all(8),
                              child: pw.Text('Rs.$total',
                                style: pw.TextStyle(
                                  color:      _gold,
                                  fontSize:   12,
                                  fontWeight:
                                    pw.FontWeight.bold))),
                          ],
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 20),

                    // Approval + Transaction row
                    pw.Row(
                      crossAxisAlignment:
                        pw.CrossAxisAlignment.start,
                      children: [

                        // Approval basis
                        pw.Expanded(child: pw.Column(
                          crossAxisAlignment:
                            pw.CrossAxisAlignment.start,
                          children: [
                            _sectionTitle('Automated Checks'),
                            pw.SizedBox(height: 8),
                            _checkItem('ML weather models validated', true),
                            _checkItem('Policy coverage active', !isFraud),
                            _checkItem('Fraud layer cleared', !isFraud),
                            _checkItem('Zero manual filing required', true),
                          ],
                        )),

                        pw.SizedBox(width: 24),

                        // Transaction details
                        pw.Expanded(child: pw.Column(
                          crossAxisAlignment:
                            pw.CrossAxisAlignment.start,
                          children: [
                            _sectionTitle('Transaction Details'),
                            pw.SizedBox(height: 8),
                            pw.Container(
                              padding:
                                const pw.EdgeInsets.all(12),
                              decoration: pw.BoxDecoration(
                                color:        _light,
                                borderRadius:
                                  pw.BorderRadius.circular(8),
                                border: pw.Border.all(
                                  color: _bdr,
                                  width: 0.5)),
                              child: pw.Column(children: [
                                _txnRow('Transaction ID', txnId),
                                pw.Divider(
                                  color: _bdr, height: 10),
                                _txnRow('Method',   'UPI'),
                                pw.Divider(
                                  color: _bdr, height: 10),
                                _txnRow('UPI ID',   derivedUpi),
                                pw.Divider(
                                  color: _bdr, height: 10),
                                _txnRow('Settlement',
                                  '< 60 seconds'),
                                pw.Divider(
                                  color: _bdr, height: 10),
                                isFraud 
                                  ? _txnRowRed('Status', 'FAILED')
                                  : _txnRowGreen('Status', 'CREDITED'),
                              ]),
                            ),
                          ],
                        )),
                      ],
                    ),

                    pw.Spacer(),

                    // Legal note
                    pw.Container(
                      width:   double.infinity,
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color:        _light,
                        borderRadius: pw.BorderRadius.circular(6),
                        border:       pw.Border.all(
                          color: _bdr, width: 0.5)),
                      child: pw.Text(
                        'This is a computer-generated receipt and does not '
                        'require a physical signature. This claim was processed '
                        'automatically using parametric insurance triggers '
                        'verified against real-time data sources. RozgarShield is '
                        'regulated under IRDAI parametric insurance guidelines. '
                        'For disputes, contact support@rozgarshield.in within 7 days.',
                        style: const pw.TextStyle(
                          fontSize:    8,
                          color:       PdfColors.grey700,
                          lineSpacing: 1.4)),
                    ),
                  ],
                ),
              ),
            ),

            // ── Navy footer ──────────────────────────────
            pw.Container(
              width:   double.infinity,
              padding: const pw.EdgeInsets.fromLTRB(
                40, 14, 40, 14),
              color:   _navy,
              child:   pw.Row(
                mainAxisAlignment:
                  pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'RozgarShield · Bengaluru, Karnataka · India',
                    style: const pw.TextStyle(
                      color:    PdfColors.white,
                      fontSize: 8)),
                  pw.Text(
                    'Generated: $dateStr $timeStr',
                    style: const pw.TextStyle(
                      color:    PdfColors.white,
                      fontSize: 8)),
                  pw.Text(
                    'support@rozgarshield.in',
                    style: const pw.TextStyle(
                      color:    PdfColors.white,
                      fontSize: 8)),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    final bytes = await pdf.save();
    await Printing.sharePdf(
      bytes:    bytes,
      filename: 'RozgarShield_Claim_$claimId.pdf',
    );
  }

  // ── Helpers ──────────────────────────────────────────

  static pw.Widget _infoBox({
    required String         title,
    required List<List<String>> items,
  }) =>
    pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title,
          style: pw.TextStyle(
            color:      _navy,
            fontSize:   10,
            fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color:        _light,
            borderRadius: pw.BorderRadius.circular(6),
            border:       pw.Border.all(
              color: _bdr, width: 0.5)),
          child: pw.Column(
            children: items.map((it) =>
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                  vertical: 3),
                child: pw.Row(children: [
                  pw.SizedBox(
                    width: 72,
                    child: pw.Text(it[0],
                      style: const pw.TextStyle(
                        color:    PdfColors.grey600,
                        fontSize: 9))),
                  pw.Expanded(child: pw.Text(it[1],
                    style: pw.TextStyle(
                      color:      _navy,
                      fontSize:   9,
                      fontWeight: pw.FontWeight.bold))),
                ]),
              )
            ).toList(),
          ),
        ),
      ],
    );

  static pw.Widget _sectionTitle(String t) =>
    pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(t,
          style: pw.TextStyle(
            color:      _navy,
            fontSize:   10,
            fontWeight: pw.FontWeight.bold)),
        pw.Container(
          height: 2,
          width:  36,
          margin: const pw.EdgeInsets.only(top: 3),
          color:  _gold),
      ],
    );

  static pw.Widget _th(String t) => pw.Padding(
    padding: const pw.EdgeInsets.all(7),
    child:   pw.Text(t,
      style: pw.TextStyle(
        color:      PdfColors.white,
        fontSize:   9,
        fontWeight: pw.FontWeight.bold)),
  );

  static pw.Widget _td(String t) => pw.Padding(
    padding: const pw.EdgeInsets.all(7),
    child:   pw.Text(t,
      style: const pw.TextStyle(
        color: PdfColors.grey800, fontSize: 9)),
  );

  static pw.Widget _tdGold(String t) => pw.Padding(
    padding: const pw.EdgeInsets.all(7),
    child:   pw.Text(t,
      style: pw.TextStyle(
        color:      _gold,
        fontSize:   10,
        fontWeight: pw.FontWeight.bold)),
  );

  static pw.Widget _checkItem(String t, bool pass) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 5),
    child:   pw.Row(children: [
      pw.Container(
        width: 13, height: 13,
        decoration: pw.BoxDecoration(
          color: pass ? _green : PdfColors.red,
          shape: pw.BoxShape.circle,
        ),
      ),
      pw.SizedBox(width: 6),
      pw.Text(t,
        style: const pw.TextStyle(
          color: PdfColors.grey800, fontSize: 9)),
    ]),
  );

  static pw.Widget _txnRow(String l, String v) =>
    pw.Row(
      mainAxisAlignment:
        pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(l,
          style: const pw.TextStyle(
            color: PdfColors.grey600, fontSize: 9)),
        pw.Text(v,
          style: pw.TextStyle(
            color:      _navy,
            fontSize:   9,
            fontWeight: pw.FontWeight.bold)),
      ],
    );

  static pw.Widget _txnRowGreen(String l, String v) =>
    pw.Row(
      mainAxisAlignment:
        pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(l,
          style: const pw.TextStyle(
            color: PdfColors.grey600, fontSize: 9)),
        pw.Text(v,
          style: pw.TextStyle(
            color:      _green,
            fontSize:   9,
            fontWeight: pw.FontWeight.bold)),
      ],
    );

  static pw.Widget _txnRowRed(String l, String v) =>
    pw.Row(
      mainAxisAlignment:
        pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(l,
          style: const pw.TextStyle(
            color: PdfColors.grey600, fontSize: 9)),
        pw.Text(v,
          style: pw.TextStyle(
            color:      PdfColors.red,
            fontSize:   9,
            fontWeight: pw.FontWeight.bold)),
      ],
    );
}
