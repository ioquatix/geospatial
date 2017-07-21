
require 'geospatial/map'
require 'geospatial/polygon'

require_relative 'visualization'

RSpec.describe Geospatial::Map.for_earth(30) do
	let(:ranges) {[[888899773526966272, 888899773560520703], [888899773912842240, 888899775322128383], [888899775355682816, 888899775389237247], [888899775422791680, 888899775573786623], [888899775708004352, 888899776311984127], [888899776932741120, 888899776966295551], [888899776999849984, 888899777050181631], [888899781680693248, 888899782217564159], [888899782754435072, 888899783291305983], [888899787317837824, 888899788123144191], [888899788660015104, 888899816141094911], [888899816157872128, 888899816191426559], [888899816224980992, 888899816392753151], [888899816426307584, 888899816443084799], [888899816510193664, 888899817181282303], [888899817349054464, 888899817416163327], [888899817617489920, 888899817634267135], [888899817651044352, 888899821224591359], [888899821342031872, 888899821509804031], [888899822516436992, 888899822717763583], [888899822751318016, 888899823019753471], [888900520767389696, 888900520800944127], [888900520834498560, 888900520868052991], [888900521572696064, 888900521690136575], [888900521824354304, 888900521992126463], [888900525599227904, 888900525632782335], [888900525666336768, 888900525699891199], [888900525917995008, 888900526874296319], [888900527411167232, 888900527444721663], [888900527461498880, 888900580964040703], [888900581031149568, 888900581064703999], [888900581098258432, 888900581349916671], [888900582843088896, 888900582876643327], [888900583044415488, 888900583077969919], [888900583111524352, 888900583161855999], [888900584051048448, 888900584084602879], [888900584134934528, 888900584369815551], [888900584504033280, 888900587154833407], [888900587171610624, 888900587255496703], [888900587624595456, 888900587641372671], [888900587674927104, 888900587708481535], [888900587876253696, 888900587909808127], [888900587926585344, 888900587993694207], [888900588161466368, 888900588178243583], [888900588195020800, 888900591718236159], [888900591768567808, 888900591802122239], [888900591818899456, 888900593093967871], [888900593110745088, 888900593127522303], [888900593244962816, 888900593261740031], [888900593983160320, 888900594016714751], [888900594100600832, 888900594117378047], [888900594134155264, 888900594503254015], [888900594520031232, 888900594536808447], [888900594704580608, 888900594721357823], [888900594738135040, 888900594855575551], [888900594872352768, 888900623544614911], [888900623678832640, 888900633426395135], [888900633795493888, 888900633812271103], [888900633845825536, 888900633879379967], [888900634214924288, 888900634483359743], [888900634567245824, 888900634634354687], [888900634651131904, 888900634667909119], [888900636110749696, 888900636161081343], [888900636244967424, 888900636261744639], [888900636278521856, 888900636882501631], [888900636999942144, 888900637016719359], [888900637520035840, 888900637570367487], [888900644365139968, 888900644381917183], [888900644415471616, 888900644499357695], [888900644549689344, 888900645757648895], [888900645791203328, 888900645807980543], [888900645942198272, 888900646328074239], [888900646344851456, 888900646512623615], [888900649347973120, 888900649364750335], [888900677651136512, 888900677667913727], [888900677701468160, 888900677751799807], [888900677953126400, 888900677969903615], [888912854286073856, 888912854420291583], [888912854621618176, 888912858111279103], [888912858195165184, 888912858228719615], [888912858279051264, 888912858480377855], [888912858530709504, 888912858564263935], [888912858614595584, 888912859487010815], [888912859537342464, 888912859570896895], [888912859621228544, 888912859822555135], [888912859856109568, 888912877103087615], [888912877237305344, 888912877371523071], [888912877505740800, 888912878143275007], [888912878344601600, 888912878411710463], [888912878713700352, 888912878881472511], [888912878931804160, 888912878965358591], [888912879015690240, 888912879888105471], [888912879904882688, 888912879988768767], [888912885978234880, 888912886011789311], [888912886045343744, 888912886078898175], [888912886783541248, 888912886817095679], [888912886850650112, 888912886900981759], [888912887035199488, 888912887169417215], [888912891162394624, 888912891179171839], [888912891263057920, 888912891967700991], [888912892018032640, 888912892051587071], [888912892638789632, 888912892655566847], [888912892705898496, 888912901815926783], [888912901849481216, 888912901883035647], [888912901916590080, 888912902067585023], [888912902201802752, 888912903090995199], [888912903124549632, 888912903174881279], [888912903426539520, 888912903460093951], [888912903476871168, 888912903543980031], [888912906849091584, 888912906882646015], [888912906916200448, 888912909013352447], [888912909214679040, 888912909265010687], [888912909298565120, 888912909315342335], [888912910405861376, 888912910523301887], [888912910657519616, 888912910791737343], [888912911680929792, 888912911714484223], [888912911731261440, 888912912016474111], [888912912050028544, 888912912083582975], [888912912117137408, 888913026034434047], [888913026051211264, 888913026151874559], [888913026168651776, 888913026185428991], [888913026789408768, 888913026906849279], [888913026923626496, 888913027913482239], [888913027930259456, 888913028098031615], [888913028114808832, 888913028131586047], [888913028433575936, 888913028450353151], [888913028483907584, 888913028567793663], [888913028584570880, 888913028601348095], [888913037912702976, 888913037929480191], [888913038550237184, 888913038718009343], [888913038734786560, 888913039993077759], [888913040009854976, 888913040177627135], [888913040446062592, 888913040462839807], [888913040496394240, 888913040597057535], [888913040613834752, 888913056082427903], [888913056115982336, 888913056266977279], [888913056602521600, 888913056686407679], [888913056719962112, 888913059202990079], [888913059622420480, 888913059689529343], [888913713212424192, 888913713413750783], [888913713430528000, 888913713447305215], [888913713682186240, 888913713698963455], [888913713715740672, 888913716366540799], [888913716383318016, 888913716416872447], [888913716685307904, 888913716718862335], [888913716735639552, 888913716836302847], [888913716853080064, 888913716869857279], [888913720711839744, 888913720745394175], [888913720762171392, 888913720896389119], [888913721282265088, 888913721299042303], [888913721466814464, 888913721483591679], [888913721500368896, 888913723110981631], [888913723329085440, 888913756464087039], [888913756665413632, 888913756732522495], [888913756933849088, 888913757772709887], [888913761698578432, 888913761748910079], [888913761782464512, 888913762352889855], [888913762386444288, 888913762436775935], [888913762772320256, 888913762822651903], [888913762856206336, 888913763393077247], [888913763460186112, 888913763510517759], [888913769013444608, 888913769231548415], [888913769265102848, 888913769281880063], [888913769583869952, 888913769617424383], [888913769785196544, 888913771177705471], [888913771446140928, 888913771647467519]]}
	
	it "can generate visualisation" do
		filter = Geospatial::Filter.new(subject.curve)
		
		ranges.each do |min, max|
			filter.ranges << (min..max)
		end
		
		Geospatial::Visualization.for_map(subject) do |pdf, origin|
			filter.each do |child, prefix, order|
				size = child.size
				top_left = origin + child.origin + Vector[0, size[1]]
				
				pdf.rectangle(top_left.to_a, *size.to_a)
			end
			
			pdf.fill_and_stroke
		end.render_file "kaikoura.pdf"
	end
	
	let(:kaikoura_polygon) {Geospatial::Polygon[
		Vector[173.7218528654108, -42.32817252073923],
		Vector[173.6307775307161, -42.32729039137249],
		Vector[173.5400659958715, -42.39758413896335],
		Vector[173.5446498680837, -42.43847509799515],
		Vector[173.6833471779081, -42.44870319335309],
		Vector[173.7608096128163, -42.42144813099029],
		Vector[173.7218528654108, -42.32817252073923],
	]}
	
	it "should not contain point" do
		map = Geospatial::Map.for_earth(30)
		filter = map.filter_for(kaikoura_polygon, depth: 12)
		
		#puts "filter.ranges.count: #{filter.ranges.count}"
		
		#ranges.each_with_index do |(min, max), index|
		#	puts "#{min} -> #{max} :: #{filter.ranges[index].min} -> #{filter.ranges[index].max}"
		#end
		
		location = Geospatial::Location[176.204319, -37.660294]
		point = map.point_for_object(location)
		
		#puts map.hash_for_coordinates(location.to_a)
		# 888186547785722805
		# 888900599658148001
		
		expect(filter).to_not include location
	end
end

