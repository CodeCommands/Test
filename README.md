# Salesforce Knowledge Management Revamp Demo Script

## Introduction

Good morning/afternoon everyone. Today, I'm excited to share with you our revamped knowledge management framework in Salesforce. We've made significant improvements to streamline how our five business units create, approve, and publish knowledge articles, moving from a development-dependent process to a more empowered, user-driven approach.

## Current State of Knowledge Management

Let me start by explaining our current knowledge article management process:

### Current Process Flow

1. **Request Initiation**: Application owners identify a need for a new knowledge article and add it to the development team's backlog.

2. **Development Environment Creation**: Our development team creates the knowledge article in the lowest environment (DEV).

3. **Verification Cycle**: The application team reviews and validates the knowledge article in the DEV environment.

4. **Deployment Pipeline**: Once approved, the development team deploys the knowledge article through the entire environment pipeline (DEV → QA → UAT → PROD).

5. **Publication**: The article finally becomes available to internal or external users only after completing the full deployment cycle.

### Current Challenges

This approach has several pain points:

* **Development Dependency**: Application teams must rely on the development team's availability to create or modify articles.

* **Deployment Cycle Limitations**: Articles can only be published following the predetermined deployment schedules.

* **Time to Market**: There's a significant delay between identifying the need for knowledge content and having it available to users.

* **Resource Utilization**: Our technical resources spend time on content management tasks rather than focusing on application development.

* **Limited Ownership**: Application teams lack direct control over their knowledge content lifecycle.

## Our New Revamped Process

We've redesigned our knowledge management approach with three key user personas and a streamlined workflow:

### New User Personas

1. **Knowledge Users**: End-users who access and consume knowledge articles.

2. **Knowledge Contributors**: Subject matter experts from application teams who can create new knowledge articles and submit them for approval. They cannot directly publish content.

3. **Knowledge Publishers**: Designated approvers who review, provide feedback, approve, and publish knowledge articles. They have full article lifecycle management capabilities.

### New Process Flow

1. **Article Creation**: Knowledge Contributors create articles directly in the production environment using our new Salesforce interface.

2. **Submission for Approval**: Once an article is ready, Contributors submit it through our automated approval process.

3. **Review and Feedback**: Knowledge Publishers receive approval notifications through Salesforce queues.

4. **Approval or Revision**: Publishers either approve the article for publication or send it back with feedback for revisions.

5. **Publication**: Approved articles are immediately published to the appropriate audiences without requiring a development deployment.

## Technical Implementation Details

To support this new framework, we've implemented several technical enhancements:

### 1. Record Types

We've created separate record types in the Knowledge object for each of our five business units:
* Application A Record Type
* Application B Record Type
* Application C Record Type
* Application D Record Type
* Application E Record Type

This ensures clear separation between applications while maintaining a unified knowledge base.

### 2. Data Categories Restructuring

We've reorganized our data categories to create a more intuitive hierarchy that aligns with our business structure and improves searchability.

### 3. Approval Process Automation

We've implemented:
* Custom approval processes for each business unit
* Automated notification flows
* Queue-based approval assignments
* Status tracking throughout the article lifecycle

### 4. Permission Sets and Profiles

We've created dedicated permission sets to define the three user personas, ensuring appropriate access controls:
* Knowledge User permissions
* Knowledge Contributor permissions
* Knowledge Publisher permissions

## Live Demonstration

[Note: This section would include a live walkthrough of the actual Salesforce implementation]

Let me demonstrate how the new process works:

1. I'll log in as a Knowledge Contributor and create a new article
2. I'll show how to select the appropriate record type and categories
3. I'll submit the article for approval
4. I'll switch to a Publisher account to show the approval process
5. I'll demonstrate publication and how it immediately appears to users

## Key Benefits of the New Approach

Our revamped knowledge management framework delivers several significant benefits:

### 1. Empowered Business Units

* Application teams now have direct control over their knowledge content
* No need to wait for development team availability
* Self-service article creation and management

### 2. Accelerated Time to Market

* Articles can be published as soon as they're approved
* No dependency on deployment schedules
* Critical information reaches users faster

### 3. Resource Optimization

* Development team can focus on technical work
* Subject matter experts directly contribute their knowledge
* Publishers ensure quality control

### 4. Improved Governance

* Clear approval workflows ensure content quality
* Record types maintain organizational boundaries
* Structured data categories improve findability

### 5. Scalability

* Framework accommodates all five business units
* Can easily expand to include additional applications
* Consistent process across the organization

## Implementation Timeline and Next Steps

We have successfully implemented this framework and are now ready to roll it out across all business units. Our implementation plan includes:

1. User training sessions for Contributors and Publishers
2. Migration of existing knowledge articles to the new structure
3. Gradual phase-out of the old process
4. Continuous improvement based on user feedback

## Conclusion

Our revamped knowledge management framework transforms how we create and maintain knowledge articles across our five applications. By empowering application teams, streamlining approvals, and eliminating deployment dependencies, we're making knowledge management faster, more efficient, and more responsive to business needs.

Thank you for your attention. I'm happy to answer any questions you may have about the new framework.

## Q&A Preparation

[Note: Prepare answers for anticipated questions]

* How will we migrate existing articles?
* What training will be provided to users?
* How do we handle article versions and updates?
* What happens when an article needs to be retired?



```
// Step 1: Query records

```



Account Name,Type,Phone,Description,Mission_statement__c
Office of the Secretary,Staff Office,(202) 586-5000,“Executive leadership office overseeing all Department of Energy operations, policy development, and strategic direction.”,“To lead the Department of Energy in advancing America’s energy security, environmental responsibility, and nuclear security through innovative policy and executive oversight.”
Federal Energy Regulatory Commission (FERC),Regulatory Agency,(202) 502-8000,“Independent regulatory agency overseeing interstate transmission of electricity, natural gas, and oil, ensuring fair and reliable energy markets.”,“To regulate and oversee America’s energy industries in the public interest, ensuring reliable, efficient, and sustainable energy infrastructure.”
Office of the Inspector General (IG),Oversight Office,(202) 586-4393,“Independent oversight office conducting audits, investigations, and inspections to promote efficiency and prevent fraud within DOE.”,“To provide independent oversight and promote economy, efficiency, and effectiveness in Department of Energy programs and operations.”
Office of the Ombudsman,Support Office,(202) 586-7411,“Neutral office providing assistance in resolving disputes and addressing concerns within the Department of Energy.”,“To serve as an independent resource for resolving conflicts and improving communication within the Department of Energy.”
Boards and Councils,Advisory Body,(202) 586-6450,“Advisory bodies providing expert guidance and recommendations on energy policy, research priorities, and strategic initiatives.”,“To provide expert advice and strategic guidance to support informed decision-making across Department of Energy programs and initiatives.”
Chief of Staff,Executive Office,(202) 586-5500,“Senior executive office coordinating operations, communications, and strategic initiatives for the Secretary’s office.”,“To ensure effective coordination and execution of the Secretary’s priorities and Department-wide strategic objectives.”
Office of the Under Secretary for Nuclear Security (S5) and National Nuclear Security Administration (NNSA),Security Office,(202) 586-5555,“Oversees nuclear security programs, weapons stewardship, and non-proliferation efforts to maintain America’s nuclear deterrent.”,“To enhance national security through the military application of nuclear science and technology, maintaining a safe, secure, and effective nuclear deterrent.”
Under Secretary for Nuclear Security and Administrator NNSA,Executive Office,(202) 586-5400,“Senior leadership position overseeing all nuclear security operations, weapons programs, and national security initiatives.”,“To lead America’s nuclear security enterprise, ensuring the safety, security, and effectiveness of the nuclear deterrent and non-proliferation efforts.”
Office of the Under Secretary for Science and Innovation (S4),Science Office,(202) 586-5430,“Oversees scientific research programs, innovation initiatives, and technology development across the Department of Energy.”,“To advance scientific discovery and innovation that drives America’s energy future and maintains technological leadership in energy sciences.”
Under Secretary for Science and Innovation,Executive Office,(202) 586-5431,“Senior executive leading scientific research strategy, innovation programs, and technology development initiatives.”,“To champion scientific excellence and innovation that addresses America’s energy challenges and advances our technological competitiveness.”
Office of the Under Secretary for Infrastructure (S3),Infrastructure Office,(202) 586-8000,“Manages energy infrastructure programs, grid modernization, and critical energy systems development and deployment.”,“To strengthen America’s energy infrastructure through strategic investments, modernization efforts, and resilient system development.”
Under Secretary for Infrastructure,Executive Office,(202) 586-8100,“Senior executive overseeing infrastructure development, grid modernization, and energy system resilience programs.”,“To lead the transformation of America’s energy infrastructure for a clean, reliable, and secure energy future.”
Advanced Research Projects Agency - Energy (ARPA-E),Research Agency,(202) 287-1004,“Advanced research agency developing transformational energy technologies that could fundamentally change energy generation, storage, and use.”,“To catalyze transformational breakthroughs in energy technologies through high-risk, high-reward research that advances America’s energy and economic security.”
Office of the Chief Financial Officer (CF),Financial Office,(202) 586-4171,“Manages financial operations, budget planning, and fiscal oversight for all Department of Energy programs and activities.”,“To provide exceptional financial management and stewardship that enables mission success across the Department of Energy.”
Office of the Chief Human Capital Officer (HC),Human Resources Office,(202) 586-1234,“Oversees human resources strategy, workforce development, and talent management across the Department of Energy.”,“To build and sustain a world-class workforce that drives mission excellence and advances America’s energy and security objectives.”
Office of the Chief Information Officer (IM),Information Technology Office,(202) 586-0166,“Manages information technology infrastructure, cybersecurity, and digital transformation initiatives across the Department.”,“To deliver secure, innovative, and reliable information technology solutions that enable mission success and protect critical energy infrastructure.”
Office of Congressional & Intergovernmental Affairs (CI),Legislative Affairs Office,(202) 586-5450,“Manages relationships with Congress, state and local governments to advance Department priorities and coordinate policy initiatives.”,“To foster productive partnerships with Congress and intergovernmental stakeholders that advance America’s energy security and policy objectives.”
Office of Minority Economic Impact (MI),Economic Development Office,(202) 586-8383,“Promotes minority business participation in Department programs and ensures equitable access to energy economic opportunities.”,“To advance economic equity and opportunity by ensuring meaningful participation of minority businesses in America’s clean energy economy.”
Office of Enterprise Assessments (EA),Assessment Office,(301) 903-3777,“Conducts independent assessments of safety, security, and management systems across Department facilities and operations.”,“To provide independent assessment and oversight that ensures the safety, security, and effectiveness of Department of Energy operations.”
U.S. Energy Information Administration (EIA),Statistical Agency,(202) 586-8800,“Collects, analyzes, and disseminates independent and impartial energy information to promote sound policymaking and public understanding.”,“To provide trusted, objective, and insightful energy information that enables informed decision-making by policymakers, markets, and the public.”
Office of Environment Health Safety and Security (EHSS),Safety Office,(301) 903-3467,“Ensures environmental protection, worker safety, and security compliance across all Department facilities and operations.”,“To protect workers, the public, and the environment through comprehensive safety, health, and environmental programs and oversight.”
Office of General Counsel (GC),Legal Office,(202) 586-5281,“Provides legal counsel, regulatory guidance, and litigation support for all Department programs and operations.”,“To provide exceptional legal services that enable mission success while ensuring compliance with applicable laws and regulations.”
Office of Intelligence and Counterintelligence (IN),Intelligence Office,(202) 586-2650,“Manages intelligence activities, counterintelligence programs, and security assessments to protect Department assets and information.”,“To provide intelligence support and counterintelligence protection that safeguards Department missions and America’s energy security interests.”
Office of Management (MA),Management Office,(202) 586-2550,“Oversees administrative operations, facilities management, and organizational effectiveness across the Department.”,“To provide excellent administrative and management services that enable efficient and effective Department operations.”
Office of Policy (OP),Policy Office,(202) 586-5800,“Develops and coordinates energy policy, conducts policy analysis, and provides strategic guidance on energy issues.”,“To develop and advance comprehensive energy policies that promote America’s energy security, economic competitiveness, and environmental responsibility.”
Office of Project Management (PM),Project Management Office,(202) 287-1818,“Provides project management oversight, guidance, and best practices for major Department initiatives and construction projects.”,“To ensure successful delivery of major Department projects through disciplined project management practices and oversight.”
Office of Public Affairs (PA),Communications Office,(202) 586-4940,“Manages public communications, media relations, and stakeholder engagement to inform the public about Department activities.”,“To communicate the Department’s mission, achievements, and priorities to ensure public understanding and support for America’s energy future.”
Office of Small & Disadvantaged Business Utilization (OSDBU),Business Development Office,(202) 586-7377,“Promotes small business participation in Department contracts and ensures equitable access to procurement opportunities.”,“To expand opportunities for small and disadvantaged businesses in the Department’s mission while strengthening America’s energy innovation ecosystem.”
Office of Technology Transitions (OTT),Technology Transfer Office,(202) 586-2000,“Facilitates transfer of Department technologies to private sector for commercialization and economic development.”,“To accelerate the transfer of innovative energy technologies from national laboratories to the marketplace, driving economic growth and energy innovation.”
Office of Defense Programs (NA-10),Defense Programs Office,(202) 586-2179,“Maintains the safety, security, and effectiveness of the nuclear weapons stockpile through stewardship and modernization programs.”,“To maintain a safe, secure, and effective nuclear weapons stockpile that supports America’s national security and strategic deterrent.”
Office of Defense Nuclear Nonproliferation (NA-20),Nonproliferation Office,(202) 586-0645,“Prevents nuclear proliferation and terrorism through detection, interdiction, and elimination of nuclear threats worldwide.”,“To reduce global nuclear security threats through nonproliferation, counterterrorism, and threat reduction programs worldwide.”
Naval Reactors (NA-30),Naval Nuclear Office,(202) 781-6174,“Designs, builds, and operates nuclear propulsion systems for the U.S. Navy’s fleet of nuclear-powered vessels.”,“To provide the U.S. Navy with safe, reliable, and long-lived nuclear propulsion systems that ensure maritime superiority and national defense.”
Office of Defense Nuclear Security (NA-70),Nuclear Security Office,(202) 586-8900,“Provides security and protection for nuclear materials, facilities, and information across the nuclear security enterprise.”,“To protect nuclear materials and facilities through comprehensive security programs that prevent theft, sabotage, and unauthorized access.”
Office of Infrastructure (NA-90),Infrastructure Office,(202) 586-7058,“Manages infrastructure, construction, and facility operations supporting the nuclear security mission.”,“To provide world-class infrastructure and facilities that enable the nuclear security enterprise to fulfill its critical national security mission.”
Office of Management & Budget (NA-MB),Budget Office,(202) 586-3453,“Manages budget planning, financial oversight, and resource allocation for nuclear security programs.”,“To provide effective financial management and resource planning that enables mission success across the nuclear security enterprise.”
Office of General Counsel (NA-GC),Legal Office,(202) 586-6789,“Provides legal counsel and support for nuclear security programs, operations, and regulatory compliance.”,“To deliver exceptional legal services that enable nuclear security mission success while ensuring compliance with all applicable requirements.”
Arctic Energy Office (AE),Regional Office,(907) 271-3618,“Coordinates energy programs and research specific to Arctic regions and Alaska’s unique energy challenges.”,“To address Alaska’s energy challenges through innovative programs that enhance energy security and economic development in Arctic regions.”
Office of Critical and Emerging Technologies (OCET),Technology Office,(202) 586-2345,“Identifies, develops, and protects critical and emerging technologies essential to national and energy security.”,“To maintain America’s technological edge in critical energy technologies through strategic development, protection, and deployment initiatives.”
Office of Clean Energy Demonstrations (OCED),Demonstration Office,(202) 586-7890,“Manages large-scale demonstration projects for clean energy technologies to accelerate commercial deployment.”,“To accelerate the deployment of clean energy technologies through large-scale demonstrations that prove commercial viability and drive market adoption.”
Office of Energy Efficiency & Renewable Energy (EERE),Clean Energy Office,(202) 586-9220,“Develops and deploys energy efficiency and renewable energy technologies to create a clean energy economy.”,“To lead America’s clean energy revolution through research, development, and deployment of energy efficiency and renewable energy technologies.”
Office of Fossil Energy and Carbon Management (FECM),Fossil Energy Office,(202) 586-6660,“Manages research and development of clean fossil energy technologies and carbon management solutions.”,“To develop and deploy technologies that enable clean, efficient use of fossil energy resources while advancing carbon capture and storage solutions.”
Office of Nuclear Energy (NE),Nuclear Energy Office,(202) 586-6450,“Advances nuclear energy technology development, deployment, and policy to maintain America’s nuclear energy leadership.”,“To advance nuclear energy as a clean, safe, and secure energy source that contributes to America’s energy security and climate goals.”
Office of Electricity (OE),Electricity Office,(202) 586-1411,“Leads efforts to strengthen and modernize America’s electricity delivery infrastructure and enhance grid reliability.”,“To ensure a resilient, reliable, and secure electricity system that supports America’s economy and quality of life.”
Office of Science (SC),Scientific Research Office,(301) 903-3081,“Supports fundamental scientific research that underpins energy technologies and maintains America’s scientific leadership.”,“To deliver scientific discoveries and major scientific tools that transform our understanding of nature and advance America’s energy future.”
Office of Federal Energy Management Program (FEMP),Federal Programs Office,(202) 586-5772,“Helps federal agencies reduce energy costs and environmental impact through efficiency and renewable energy programs.”,“To lead by example in advancing energy efficiency and clean energy adoption across the federal government.”
Grid Deployment Office (GDO),Grid Office,(202) 586-1934,“Accelerates deployment of clean electricity transmission and grid infrastructure to enable the clean energy transition.”,“To build the transmission infrastructure needed for a clean, reliable, and affordable electricity system that serves all Americans.”
Office of Manufacturing & Energy Supply Chains (MESC),Manufacturing Office,(202) 586-2468,“Strengthens domestic manufacturing and supply chains for clean energy technologies and critical materials.”,“To build resilient clean energy manufacturing and supply chains that create jobs and strengthen America’s energy independence.”
Office of State and Community Energy Programs (SCEP),State Programs Office,(202) 586-1885,“Partners with states, communities, and stakeholders to advance clean energy deployment and energy resilience.”,“To empower states and communities to achieve their clean energy goals through technical assistance, funding, and strategic partnerships.”
Loan Programs Office (LPO),Financing Office,(202) 287-5580,“Provides federal financing support for innovative clean energy and advanced transportation projects.”,“To accelerate deployment of innovative clean energy technologies through strategic federal financing that catalyzes private investment.”
Indian Energy Policy & Programs (IE),Tribal Programs Office,(202) 586-1272,“Supports energy development and deployment on tribal lands to promote energy sovereignty and economic development.”,“To support tribal energy sovereignty and economic development through strategic partnerships and culturally appropriate energy solutions.”
Office of Hearings and Appeals (HG),Administrative Office,(202) 287-1566,“Provides independent administrative hearings and appeals processes for Department regulatory and administrative matters.”,“To provide fair, timely, and independent resolution of administrative disputes and appeals within the Department of Energy.”
Office of International Affairs (IA),International Office,(202) 586-5935,“Manages international energy cooperation, partnerships, and diplomatic engagement on global energy issues.”,“To advance America’s energy security and climate goals through strategic international partnerships and diplomatic engagement.”
Office of Legacy Management (LM),Legacy Office,(970) 248-6070,“Manages environmental remediation and long-term stewardship of former Department sites and facilities.”,“To protect human health and the environment through responsible management of the Department’s environmental legacy.”
Deputy Under Secretary for Counter-Terrorism & Counter-Proliferation (NA-80),Counterterrorism Office,(202) 586-8765,“Leads counterterrorism and counter-proliferation efforts to prevent nuclear and radiological threats to national security.”,“To prevent and counter weapons of mass destruction terrorism through detection, response, and elimination of nuclear and radiological threats.”
Associate Administrator for Emergency Management (NA-40),Emergency Management Office,(202) 586-9892,“Coordinates emergency response capabilities and crisis management for nuclear security incidents and operations.”,“To ensure rapid and effective response to nuclear emergencies through comprehensive planning, training, and coordination capabilities.”
Associate Administrator for Environment Safety & Health (NA-ESH),Safety Office,(301) 903-2407,“Ensures environmental protection and worker safety across all nuclear security operations and facilities.”,“To protect workers, the public, and the environment through comprehensive safety and environmental programs in nuclear security operations.”
Associate Administrator for Partnership & Acquisition Services (NA-APL),Acquisition Office,(202) 586-7654,“Manages partnerships, contracts, and acquisition services for nuclear security programs and operations.”,“To deliver exceptional acquisition and partnership services that enable nuclear security mission success through strategic relationships.”
Associate Administrator for Information Management & Chief Information Officer (NA-IM),Information Systems Office,(202) 586-5432,“Manages information technology, cybersecurity, and data management for nuclear security operations.”,“To provide secure, reliable, and innovative information technology solutions that enable nuclear security mission success.”