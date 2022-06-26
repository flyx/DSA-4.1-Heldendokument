package dsa41held;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.net.*;

// taken from https://stackoverflow.com/a/34409142/347964
// with minor changes

public class MultipartUtility {
    private final String boundary;
    private static final String LINE_FEED = "\r\n";
    private HttpURLConnection httpConn;
    private static final String charset = "UTF-8";
    private OutputStream outputStream;
    private PrintWriter writer;

    /**
     * This constructor initializes a new HTTP POST request with content type
     * is set to multipart/form-data
     */
    public MultipartUtility(HttpURLConnection conn) throws IOException {
        // creates a unique boundary based on time stamp
        boundary = "---" + System.currentTimeMillis() + "---";
        httpConn = conn;
        httpConn.setUseCaches(false);
        httpConn.setDoOutput(true);    // indicates POST method
        httpConn.setDoInput(true);
        httpConn.setRequestProperty("Content-Type",
                "multipart/form-data; boundary=" + boundary);
        outputStream = httpConn.getOutputStream();
        writer = new PrintWriter(new OutputStreamWriter(outputStream, charset),
                true);
    }

    /**
     * Adds a form field to the request
     */
    public void addFormField(String name, String value) {
        writer.append("--" + boundary).append(LINE_FEED);
        writer.append("Content-Disposition: form-data; name=\"" + name + "\"")
                .append(LINE_FEED);
        writer.append("Content-Type: text/plain; charset=" + charset).append(
                LINE_FEED);
        writer.append(LINE_FEED);
        writer.append(value);
        writer.flush();
        writer.append(LINE_FEED);
    }

    /**
     * Adds a upload file section to the request
     *
     * @param fieldName     name attribute in <input type="file" name="..." />
     * @param content       binary content of the file
     * @param contentType   the file's Content-Type
     * @throws IOException
     */
    public void addFilePart(String fieldName, String fileName, InputStream content, String contentType)
            throws IOException {
        writer.append("--" + boundary).append(LINE_FEED);
        writer.append(
                "Content-Disposition: form-data; name=\"" + fieldName
                        + "\"; filename=\"" + fileName + "\"")
                .append(LINE_FEED);
        writer.append(
                "Content-Type: " + contentType)
                .append(LINE_FEED);
        writer.append("Content-Transfer-Encoding: binary").append(LINE_FEED);
        writer.append(LINE_FEED);
        writer.flush();

        byte[] buffer = new byte[4096];
        int bytesRead = -1;
        while ((bytesRead = content.read(buffer)) != -1) {
            outputStream.write(buffer, 0, bytesRead);
        }
        outputStream.flush();
        content.close();
        writer.append(LINE_FEED);
        writer.flush();
    }

    /**
     * Adds a header field to the request.
     *
     * @param name  - name of the header field
     * @param value - value of the header field
     */
    public void addHeaderField(String name, String value) {
        writer.append(name + ": " + value).append(LINE_FEED);
        writer.flush();
    }

    /**
     * Completes the request and receives response from the server.
     *
     * @return a list of Strings as response in case the server returned
     * status OK, otherwise an exception is thrown.
     * @throws IOException
     */
    public byte[] finish() throws IOException {
        writer.append(LINE_FEED).flush();
        writer.append("--" + boundary + "--").append(LINE_FEED);
        writer.close();

        // checks server's status code first
        int status = httpConn.getResponseCode();
        if (status == HttpURLConnection.HTTP_OK) {
            byte[] ret = httpConn.getInputStream().readAllBytes();
            httpConn.disconnect();
            return ret;
        } else {
            throw new IOException("Server returned non-OK status: " + status);
        }
    }
}
