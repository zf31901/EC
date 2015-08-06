//
//  RegisterViewController.m
//  EwtStores
//
//  Created by Harry on 13-12-2.
//  Copyright (c) 2013年 Harry. All rights reserved.
//

#import "RegisterViewController.h"
#import "RegisterAuthCodeViewController.h"
#import <CoreText/CoreText.h>

#import "HTTPRequest.h"
#import "JSONKit.h"
#import "ActivityObj.h"

@interface RegisterViewController ()
{
    UIButton    *nextBtn;
    UITextField *phoneNumTF;
    BOOL        isAgreement;
    
    UITextView  *ewtAgreementDetailView;
    
    NSUInteger  secondNum;
    RegisterAuthCodeViewController *registerACC;
    
}

@end

@implementation RegisterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    RegisterAuthCodeViewController *registerAVC = [RegisterAuthCodeViewController shareInstance];
    registerACC = registerAVC;
    registerAVC._delegate = self;
    
    [self hiddenRightBtn];
    
    [self loadBaseView];
    if(self.isQuickRegist){
        [self setNavBarTitle:@"快速注册"];
        [MobClick event:KSZC];
    }else{
        [self setNavBarTitle:@"注册"];
        [MobClick event:ZC];
    }
}

#pragma mark viewBuild
- (void)loadBaseView
{
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(6, Navbar_Height + 25, 303, 48)]];
    [bgView setUserInteractionEnabled:YES];
    [bgView setImage:[UIImage imageNamed:@"cell-bg-single"]];
    [self.view addSubview:bgView];
    
    phoneNumTF = [GlobalMethod BuildTextFieldWithFrame:CGRectMake(10, 10, 283, 28) andPlaceholder:@"请输入手机号码"];
    [phoneNumTF setDelegate:self];
    [phoneNumTF setKeyboardType:UIKeyboardTypeNumberPad];
    [bgView addSubview:phoneNumTF];
    
    nextBtn = [GlobalMethod BuildButtonWithFrame:CGRectMake(6, bgView.bottom + 25, 303, 44)
                                       andOffImg:@"regist_next_off"
                                        andOnImg:@"regist_next_on"
                                       withTitle:@"下一步"];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (_isQuickRegist) {
        [nextBtn addTarget:self action:@selector(nextToQuickRegisterNews:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [nextBtn addTarget:self action:@selector(nextToRegisterNews:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.view addSubview:nextBtn];
    
    UIButton *agreementBtn = [GlobalMethod BuildButtonWithFrame:CGRectMake(16, nextBtn.bottom + 20, 118, 13)
                                                      andOffImg:nil
                                                       andOnImg:nil
                                                      withTitle:@"点击下一步表示同意"];
    [agreementBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [agreementBtn setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:agreementBtn];
    
    UILabel *ewtLb = [GlobalMethod BuildLableWithFrame:CGRectMake(agreementBtn.right, nextBtn.bottom + 19, 140, 13)
                                              withFont:[UIFont systemFontOfSize:12]
                                              withText:@"爱心天地用户服务协议"];
    [ewtLb setTextColor:RGB(0, 117, 169)];
    [ewtLb setUserInteractionEnabled:YES];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:@"爱心天地用户服务协议"];
    [attString addAttribute:(NSString *)kCTUnderlineColorAttributeName
                      value:(id)[NSNumber numberWithInt:kCTUnderlineStyleSingle]
                      range:NSMakeRange(0, 8)];
    [ewtLb setAttributedText:attString];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ewtAgreemetnDetail)];
    [ewtLb addGestureRecognizer:tap];
    [self.view addSubview:ewtLb];
}

- (void)loadEwtAgreementDetailView
{
    NSString *detailString = @"网通用户服务协议\n\n一、总则\n1．1　用户应当同意本协议的条款并按照页面上的提示完成全部的注册程序。用户在进行注册程序过程中点击\"同意\"按钮即表示用户与网通公司达成协议，完全接受本协议项下的全部条款。\n1．2　用户注册成功后，网通将给予每个用户一个用户帐号及相应的密码，该用户帐号和密码由用户负责保管；用户应当对以其用户帐号进行的所有活动和事件负法律责任。\n1．3　用户可以使用网通各个频道单项服务，当用户使用网通各单项服务时，用户的使用行为视为其对该单项服务的服务条款以及网通在该单项服务中发出的各类公告的同意。\n1．4　网通会员服务协议以及各个频道单项服务条款和公告可由网通公司随时更新，且无需另行通知。您在使用相关服务时,应关注并遵守其所适用的相关条款。\n您在使用网通提供的各项服务之前，应仔细阅读本服务协议。如您不同意本服务协议及/或随时对其的修改，您可以主动取消网通提供的服务；您一旦使用网通服务，即视为您已了解并完全同意本服务协议各项内容，包括网通对服务协议随时所做的任何修改，并成为网通用户。\n\n二、注册信息和隐私保护\n2．1　网通帐号（即网通用户ID）的所有权归网通，用户完成注册申请手续后，获得网通帐号的使用权。用户应提供及时、详尽及准确的个人资料，并不断更新注册资料，符合及时、详尽准确的要求。所有原始键入的资料将引用为注册资料。如果因注册信息不真实而引起的问题，并对问题发生所带来的后果，网通不负任何责任。\n2．2　用户不应将其帐号、密码转让或出借予他人使用。如用户发现其帐号遭他人非法使用，应立即通知网通。因黑客行为或用户的保管疏忽导致帐号、密码遭他人非法使用，网通不承担任何责任。\n2．3　网通不对外公开或向第三方提供单个用户的注册资料，除非：\n（1）事先获得用户的明确授权；\n（2）只有透露你的个人资料，才能提供你所要求的产品和服务；\n（3）根据有关的法律法规要求；\n（4）按照相关政府主管部门的要求；\n（5）为维护网通的合法权益。\n2．4　在你注册网通帐户，使用其他网通产品或服务，访问网通网页, 或参加促销和有奖游戏时，网通会收集你的个人身份识别资料，并会将这些资料用于：改进为你提供的服务及网页内容。\n\n三、使用规则\n3．1　用户在使用网通服务时，必须遵守中华人民共和国相关法律法规的规定，用户应同意将不会利用本服务进行任何违法或不正当的活动，包括但不限于下列行为∶\n（1）上载、展示、张贴、传播或以其它方式传送含有下列内容之一的信息：\n1） 反对宪法所确定的基本原则的； 2） 危害国家安全，泄露国家秘密，颠覆国家政权，破坏国家统一的； 3） 损害国家荣誉和利益的； 4） 煽动民族仇恨、民族歧视、破坏民族团结的； 5） 破坏国家宗教政策，宣扬邪教和封建迷信的； 6） 散布谣言，扰乱社会秩序，破坏社会稳定的； 7） 散布淫秽、色情、赌博、暴力、凶杀、恐怖或者教唆犯罪的； 8） 侮辱或者诽谤他人，侵害他人合法权利的； 9） 含有虚假、有害、胁迫、侵害他人隐私、骚扰、侵害、中伤、粗俗、猥亵、或其它道德上令人反感的内容； 10） 含有中国法律、法规、规章、条例以及任何具有法律效力之规范所限制或禁止的其它内容的；\n（2）不得为任何非法目的而使用网络服务系统；\n（3）不利用网通服务从事以下活动：\n1) 未经允许，进入计算机信息网络或者使用计算机信息网络资源的；\n2) 未经允许，对计算机信息网络功能进行删除、修改或者增加的；\n3) 未经允许，对进入计算机信息网络中存储、处理或者传输的数据和应用程序进行删除、修改或者增加的；\n4) 故意制作、传播计算机病毒等破坏性程序的；\n5) 其他危害计算机信息网络安全的行为。\n3．2　用户违反本协议或相关的服务条款的规定，导致或产生的任何第三方主张的任何索赔、要求或损失，包括合理的律师费，您同意赔偿网通与合作公司、关联公司，并使之免受损害。对此，网通有权视用户的行为性质，采取包括但不限于删除用户发布信息内容、暂停使用许可、终止服务、限制使用、回收网通帐号、追究法律责任等措施。对恶意注册网通帐号或利用网通帐号进行违法活动、捣乱、骚扰、欺骗、其他用户以及其他违反本协议的行为，网通有权回收其帐号。同时，网通公司会视司法部门的要求，协助调查。\n3．3　用户不得对本服务任何部分或本服务之使用或获得，进行复制、拷贝、出售、转售或用于任何其它商业目的。\n3．4　用户须对自己在使用网通服务过程中的行为承担法律责任。用户承担法律责任的形式包括但不限于：对受到侵害者进行赔偿，以及在网通公司首先承担了因用户行为导致的行政处罚或侵权损害赔偿责任后，用户应给予网通公司等额的赔偿。\n\n四、服务内容\n4．1　网通网络服务的具体内容由网通根据实际情况提供。\n4．2　除非本服务协议另有其它明示规定，网通所推出的新产品、新功能、新服务，均受到本服务协议之规范。\n4．3　为使用本服务，您必须能够自行经有法律资格对您提供互联网接入服务的第三方，进入国际互联网，并应自行支付相关服务费用。此外，您必须自行配备及负责与国际联网连线所需之一切必要装备，包括计算机、数据机或其它存取装置。\n4．4　鉴于网络服务的特殊性，用户同意网通有权不经事先通知，随时变更、中断或终止部分或全部的网络服务（包括收费网络服务）。网通不担保网络服务不会中断，对网络服务的及时性、安全性、准确性也都不作担保。\n4．5　网通需要定期或不定期地对提供网络服务的平台或相关的设备进行检修或者维护，如因此类情况而造成网络服务（包括收费网络服务）在合理时间内的中断，网通无需为此承担任何责任。网通保留不经事先通知为维修保养、升级或其它目的暂停本服务任何部分的权利。\n4．6　本服务或第三人可提供与其它国际互联网上之网站或资源之链接。由于网通无法控制这些网站及资源，您了解并同意，此类网站或资源是否可供利用，网通不予负责，存在或源于此类网站或资源之任何内容、广告、产品或其它资料，网通亦不予保证或负责。因使用或依赖任何此类网站或资源发布的或经由此类网站或资源获得的任何内容、商品或服务所产生的任何损害或损失，网通不承担任何责任。\n4．7　用户明确同意其使用网通网络服务所存在的风险将完全由其自己承担。用户理解并接受下载或通过网通服务取得的任何信息资料取决于用户自己，并由其承担系统受损、资料丢失以及其它任何风险。网通对在服务网上得到的任何商品购物服务、交易进程、招聘信息，都不作担保。\n4．8　6个月未登陆的帐号，网通保留关闭的权利。\n4．9　网通有权于任何时间暂时或永久修改或终止本服务（或其任何部分），而无论其通知与否，网通对用户和任何第三人均无需承担任何责任。\n4．10　终止服务\n您同意网通得基于其自行之考虑，因任何理由，包含但不限于长时间未使用，或网通认为您已经违反本服务协议的文字及精神，终止您的密码、帐号或本服务之使用（或服务之任何部分），并将您在本服务内任何内容加以移除并删除。您同意依本服务协议任何规定提供之本服务，无需进行事先通知即可中断或终止，您承认并同意，网通可立即关闭或删除您的帐号及您帐号中所有相关信息及文件，及/或禁止继续使用前述文件或本服务。此外，您同意若本服务之使用被中断或终止或您的帐号及相关信息和文件被关闭或删除，网通对您或任何第三人均不承担任何责任。\n\n\n五、知识产权和其他合法权益（包括但不限于名誉权、商誉权）\n5．1　用户专属权利\n网通尊重他人知识产权和合法权益，呼吁用户也要同样尊重知识产权和他人合法权益。若您认为您的知识产权或其他合法权益被侵犯，请按照以下说明向网通提供资料∶\n请注意：如果权利通知的陈述失实，权利通知提交者将承担对由此造成的全部法律责任（包括但不限于赔偿各种费用及律师费）。如果上述个人或单位不确定网络上可获取的资料是否侵犯了其知识产权和其他合法权益，网通建议该个人或单位首先咨询专业人士。\n为了网通有效处理上述个人或单位的权利通知，请使用以下格式（包括各条款的序号）：\n1. 权利人对涉嫌侵权内容拥有知识产权或其他合法权益和/或依法可以行使知识产权或其他合法权益的权属证明；\n2. 请充分、明确地描述被侵犯了知识产权或其他合法权益的情况并请提供涉嫌侵权的第三方网址（如果有）。\n3. 请指明涉嫌侵权网页的哪些内容侵犯了第2项中列明的权利。\n4. 请提供权利人具体的联络信息，包括姓名、身份证或护照复印件（对自然人）、单位登记证明复印件（对单位）、通信地址、电话号码、传真和电子邮件。\n5. 请提供涉嫌侵权内容在信息网络上的位置（如指明您举报的含有侵权内容的出处，即：指网页地址或网页内的位置）以便我们与您举报的含有侵权内容的网页的所有权人/管理人联系。\n6. 请在权利通知中加入如下关于通知内容真实性的声明： “我保证，本通知中所述信息是充分、真实、准确的，如果本权利通知内容不完全属实，本人将承担由此产生的一切法律责任。”\n7. 请您签署该文件，如果您是依法成立的机构或组织，请您加盖公章。\n请您把以上资料和联络方式书面发往以下地址：\n深圳市网通电子商务有限公司\n深圳市南海大道花园城数码大厦A座8楼(互联网电子商务基地)\n5．2　对于用户通过网通服务上传到网通网站上可公开获取区域的任何内容，用户同意网通在全世界范围内具有免费的、永久性的、不可撤销的、非独家的和完全再许可的权利和许可，以使用、复制、修改、改编、出版、翻译、据以创作衍生作品、传播、表演和展示此等内容（整体或部分），和/或将此等内容编入当前已知的或以后开发的其他任何形式的作品、媒体或技术中。\n5．3　网通拥有本网站内所有资料的版权。任何被授权的浏览、复制、打印和传播属于本网站内的资料必须符合以下条件：\n所有的资料和图象均以获得信息为目的；\n所有的资料和图象均不得用于商业目的；\n所有的资料、图象及其任何部分都必须包括此版权声明；\n网通旗下网站（www.ewt.cc、zz.ewt.cc、sc.ewt.cc、bh.ewt.cc、english.ewt.cc、www.ewtpay.com、wl.ewt.cc、rj.ewt.cc、im.ewt.cc）所有的产品、技术与所有程序均属于网通知识产权，在此并未授权。\n“EWT”, “网通”及相关图形等为网通的注册商标。\n未经网通许可，任何人不得擅自（包括但不限于：以非法的方式复制、传播、展示、镜像、上载、下载）使用。否则，网通将依法追究法律责任。\n\n\n六、青少年用户特别提示\n\n青少年用户必须遵守全国青少年网络文明公约：\n要善于网上学习，不浏览不良信息；要诚实友好交流，不侮辱欺诈他人；要增强自护意识，不随意约会网友；要维护网络安全，不破坏网络秩序；要有益身心健康，不沉溺虚拟时空。\n\n\n七、其他\n\n7．1　本协议的订立、执行和解释及争议的解决均应适用中华人民共和国法律。\n7．2　如双方就本协议内容或其执行发生任何争议，双方应尽量友好协商解决；协商不成时，任何一方均可向网通所在地的人民法院提起诉讼。\n7．3　网通未行使或执行本服务协议任何权利或规定，不构成对前述权利或权利之放弃。\n7．4　如本协议中的任何条款无论因何种原因完全或部分无效或不具有执行力，本协议的其余条款仍应有效并且有约束力。\n请您在发现任何违反本服务协议以及其他任何单项服务的服务条款、网通各类公告之情形时，通知网通。您可以通过如下联络方式同网通联系∶\n深圳市网通电子商务有限公司\n深圳市南海大道花园城数码大厦A座8楼(互联网电子商务基地)";
    
    ewtAgreementDetailView = [[UITextView alloc] initWithFrame:[GlobalMethod AdapterIOS6_7ByIOS6Frame:CGRectMake(0, Navbar_Height, Main_Size.width, Main_Size.height - StatusBar_Height - Navbar_Height)]];
    [ewtAgreementDetailView setEditable:NO];
    [ewtAgreementDetailView setText:detailString];
    [self.view addSubview:ewtAgreementDetailView];
    [self.view bringSubviewToFront:ewtAgreementDetailView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenEwtAgreeDetailView)];
    [ewtAgreementDetailView setUserInteractionEnabled:YES];
    [ewtAgreementDetailView addGestureRecognizer:tap];
    
    isAgreement = YES;
}

- (void)removewEwtAgreementDetailView
{
    [ewtAgreementDetailView removeFromSuperview];
    ewtAgreementDetailView = nil;
}

#pragma mark viewAction
- (void)nextToRegisterNews:(UIButton *)nextBtn
{
    DLog(@"注册界面，输入手机下一步");
    
    [phoneNumTF resignFirstResponder];
    
    NSDictionary *parameters = @{@"phone": phoneNumTF.text};
    if (registerACC.phoneNum != nil && ![registerACC.phoneNum isEqualToString:phoneNumTF.text]) {
        registerACC = [RegisterAuthCodeViewController shareInstance];
        registerACC._delegate = self;
        secondNum = 0;
    }
    if (secondNum == 0) {
        registerACC.secondNum = 60;
        
        BLOCK_SELF(RegisterViewController);
        HTTPRequest *hq = [HTTPRequest shareInstance_myapi];
        
        [hq GETURLString:REGISTER_SEND_PHONE userCache:NO parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObj) {
            NSDictionary *rqDic = (NSDictionary *)responseObj;
            if([rqDic[HTTP_STATE] boolValue]){
                NSArray *dataArr = (NSArray *)[rqDic[HTTP_DATA] objectFromJSONString];
                NSDictionary *dic = (NSDictionary *)dataArr;
                DLog(@"sessionkey:%@",dic[@"sessionkey"]);
                registerACC.phoneNum = phoneNumTF.text;
                registerACC.sessionkey = dic[@"sessionkey"];
                [registerACC setIsComingFromRegister:YES];
                [self.navigationController pushViewController:registerACC animated:YES];
                
            }else{
                NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
                [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@ , %@",operation,error);
            [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
        }];
    } else {
        registerACC.secondNum = secondNum;
        registerACC.phoneNum = phoneNumTF.text;
        [registerACC setIsComingFromRegister:YES];
        [self.navigationController pushViewController:registerACC animated:YES];
    }
}

- (void)nextToQuickRegisterNews:(UIButton *)nextBtn{
    DLog(@"快速注册，输入手机下一步");
    [phoneNumTF resignFirstResponder];
    NSDictionary *parameters = @{@"phone": phoneNumTF.text};
    if (registerACC.phoneNum != nil && ![registerACC.phoneNum isEqualToString:phoneNumTF.text]) {
        registerACC = [RegisterAuthCodeViewController shareInstance];
        registerACC._delegate = self;
        secondNum = 0;
    }
    if (secondNum == 0) {
        registerACC.secondNum = 60;
        
        BLOCK_SELF(RegisterViewController);
        HTTPRequest *hq = [HTTPRequest shareInstance_myapi];
        
        [hq GETURLString:QUICKREGISTER_SEND_PHONE userCache:NO parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObj) {
            NSDictionary *rqDic = (NSDictionary *)responseObj;
            if([rqDic[HTTP_STATE] boolValue]){
                NSArray *dataArr = (NSArray *)[rqDic[HTTP_DATA] objectFromJSONString];
                NSDictionary *dic = (NSDictionary *)dataArr;
                DLog(@"sessionkey:%@",dic[@"sessionkey"]);
                registerACC.phoneNum = phoneNumTF.text;
                registerACC.sessionkey = dic[@"sessionkey"];
                [registerACC setIsComingFromQuickRegister:YES];
                [self.navigationController pushViewController:registerACC animated:YES];
            }else{
                NSLog(@"errorMsg: %@",rqDic[HTTP_MSG]);
                [self showHUDInView:block_self.view WithText:rqDic[HTTP_MSG] andDelay:LOADING_TIME];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@ , %@",operation,error);
            [self showHUDInView:block_self.view WithText:NETWORKERROR andDelay:LOADING_TIME];
        }];
    } else {
        registerACC.secondNum = secondNum;
        registerACC.phoneNum = phoneNumTF.text;
        [registerACC setIsComingFromQuickRegister:YES];
        [self.navigationController pushViewController:registerACC animated:YES];
    }

}

- (void)agreementAction:(UIButton *)agreementBtn
{
    isAgreement = !isAgreement;
    
    DLog(@"%@ ewt协议",isAgreement?@"同意":@"取消");
    
    if(isAgreement)
    {
        [nextBtn setEnabled:YES];
    }
    else
    {
        [nextBtn setEnabled:NO];
    }
}

- (void)ewtAgreemetnDetail
{
    DLog(@"查看ewt协议详情");
    
    [phoneNumTF resignFirstResponder];
    [self loadEwtAgreementDetailView];
}

- (void)hiddenEwtAgreeDetailView
{
    
    isAgreement = NO;
    [self removewEwtAgreementDetailView];
}

- (void)leftBtnAction:(UIButton *)btn
{
    if (isAgreement) {
        [self hiddenEwtAgreeDetailView];
    } else {
        [super leftBtnAction:btn];
    }
}

#pragma mark ShareDataDelegate
- (void)shareValue:(NSUInteger)value
{
    secondNum = value;
    DLog(@"value:%d--------secondNum:%d",value,secondNum);
}

#pragma mark UItextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
