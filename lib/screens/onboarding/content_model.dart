class UnbordingContent {
  String image;
  String title;
  String discription;

  UnbordingContent({required this.image, required this.title, required this.discription});
}

List<UnbordingContent> contents = [
  UnbordingContent(
    title: 'Welcome to BK Petaholic',
    image: 'assets/images/dogwelcome1.png',
    discription: "Welcome to BK Petaholic! "
    "We provide top-quality care for your pets, ensuring their health and happiness at every step."
  ),
  UnbordingContent(
    title: 'Veterinary Services',
    image: 'assets/images/dogwelcome3.png',
    discription: "Our team of experienced veterinarians is here to provide comprehensive medical care. "
    "From routine checkups to specialized treatments, we've got your pets covered."
  ),
  UnbordingContent(
    title: 'Emergency Care',
    image: 'assets/images/dogwelcome2.png',
    discription: "In urgent situations, BK Petaholic is here for you. "
    "Our clinic offers round-the-clock emergency services to ensure your pets get the care they need, when they need it most."
  ),
];
