public class Client {

    public static void main(String[] args) {
        Socket socket = null;
        int PORT = 2000;

        try {
            socket = new Socket("localhost", PORT);
        } catch (UnknownHostException e) {
            System.out.println("Unknown Host");
            socket = null;
        } catch (IOException e) {
            System.out.println("Cant connect to server at 2000.");
            socket = null;
        }

        if (socket == null) {
            System.exit(1);
        }
        try {
            File file = new File("/Users/Chris/Desktop/testfile1.txt");
            byte[] bytes = new byte[8192];
            FileInputStream fileStream = new FileInputStream(file);
            BufferedInputStream buffStream = new BufferedInputStream(fileStream);
            OutputStream out = socket.getOutputStream();

            int count;

            while ((count = buffStream.read(bytes)) > 0) {
                out.write(bytes, 0, count);
            }
            out.flush();
            out.write('\r');
            out.write('\b');

            BufferedReader inFromServer
                = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            String result = "";
            int temp;
            while ((temp = inFromServer.read()) > 0) {
                result += (char)temp;
            }
            System.out.println("Result: " + result);
            out.close();
            fileStream.close();
            buffStream.close();
        } catch (IOException e) {
            System.out.println("Exception: " + e.getLocalizedMessage());
            e.printStackTrace();
        } finally {
            try {
                socket.close();
            } catch (Exception e) {
                e.getLocalizedMessage();
                e.printStackTrace();
            }
        }
    }
}
